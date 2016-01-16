require 'cows_bulls_arena/server/model'

module CowsBullsArena
  module Server
    class Controller
      attr_accessor :client

      def initialize(lobby = nil)
        @client = nil
        @active_sessions = {}
        @lobby = lobby || CowsBullsArena::Server::Model::Lobby.new
      end

      def sign_in(client_id, data)
        return if data.nil? || data.strip.empty?

        name = data.strip
        result = @lobby.sign_in name
        if result
          @active_sessions[name] = client_id
          ticket = { 'name' => name, 'code' => result.code }
          send client_id, 'sign-in-success', ticket
        else
          fail_sign_in client_id
        end
      end

      def lobby_game_list(client_id, data)
        if validate data
          send client_id, 'lobby-game-list', @lobby.game_list
        else
          fail_sign_in client_id
        end
      end

      def sign_out(client_id, data)
        if validate data
          name = data['ticket']['name']
          @lobby.sign_out name
          @active_sessions.delete name if @active_sessions.key? name
        else
          fail_sign_in client_id
        end
      end

      def new_game(client_id, data)
        if validate data
          return unless data.key? 'options'

          options = Model::GameOptions.new data['options']
          create_game_with_options client_id, options, data if options.valid?
          new_game_fail client_id, :validation unless options.valid?
        else
          fail_sign_in client_id
        end
      end

      def join(client_id, data)
        if validate data
          return unless data.key? 'game'

          if @lobby.join data['ticket']['name'], data['game']
            send client_id, 'join', data['game']
            broadcast_game_details data['game']
          else
            send client_id, 'lobby-fail', "Could not join '#{data['game']}'."
          end
        else
          fail_sign_in client_id
        end
      end

      def game_details(client_id, data)
        if validate data
          return unless data.key? 'game'

          details = details_viewmodel(@lobby.game_details(data['game']))
          send client_id, 'game-details', details unless details.nil?

          fail_message = "Could not get details of '#{data['game']}'."
          send client_id, 'lobby-fail', fail_message if details.nil?
        else
          fail_sign_in client_id
        end
      end

      def leave(client_id, data)
        if validate data
          return unless data.key? 'game'

          game = data['game']
          player = data['ticket']['name']
          broadcast_game_details game if @lobby.leave player, game
        else
          fail_sign_in client_id
        end
      end

      def ask(client_id, data)
        if validate data
          return unless data.key?('game') && data.key?('question')

          game = data['game']
          player = data['ticket']['name']
          round = @lobby.game_details(data['game']).round
          result = @lobby.ask player, game, data['question'].split('')
          unless result.nil?
            result.question = result.question.join ''
            send(
              client_id,
              'answer',
              'player' => player,
              'game' => game,
              'result' => result.marshal_dump,
              'round' => round)

            broadcast_game_details game
            broadcast_answer game, player, result.answer, round
          end
        else
          fail_sign_in client_id
        end
      end

      private

      def send(client_id, action, data = nil)
        @client.publish(
          '/client',
          'target' => client_id,
          'action' => action,
          'data' => data) unless @client.nil?
      end

      def fail_sign_in(client_id)
        send client_id, 'sign-in-fail'
      end

      def new_game_fail(client_id, reason, name = nil)
        if reason == :validation
          message = 'You have tried to create a game with some invalid options.'
        elsif reason == :unique
          message = "Please choose another name for the game. '#{name}' is taken."
        end
        send client_id, 'new-game-fail', message
      end

      def validate(data)
        return false if data.nil?
        return false unless data.key? 'ticket'

        ticket = data['ticket']
        return false if ticket.nil?
        return false unless ticket.key?('name') && ticket.key?('code')
        @lobby.validate_player ticket['name'], ticket['code']
      end

      def broadcast_game_list
        game_list = @lobby.game_list
        @active_sessions.each_value do |client_id|
          send client_id, 'lobby-game-list', game_list
        end
      end

      def broadcast_game_details(game)
        details = details_viewmodel(@lobby.game_details(game))
        broadcast_to_game game, 'game-details', details
      end

      def broadcast_answer(game, player, answer, round)
        broadcast_to_game(
          game,
          'answer-spy',
          'game' => game,
          'player' => player,
          'answer' => answer,
          'round' => round)
      end

      def broadcast_to_game(game, action, data)
        details = @lobby.game_details game
        unless details.nil?
          details.players.each do |player|
            if @active_sessions.key? player
              send @active_sessions[player], action, data
            end
          end
        end
      end

      def end_turn_callback(details)
        broadcast_game_details details.options.name
      end

      def details_viewmodel(details)
        return nil if details.nil?
        result = details.marshal_dump
        result[:options] = result[:options].to_h unless result[:options].nil?
        result
      end

      def create_game_with_options(client_id, options, data)
        if @lobby.new_game options, method(:end_turn_callback)
          data['game'] = options.name
          broadcast_game_list
          join client_id, data
        else
          new_game_fail client_id, :unique, options.name
        end
      end
    end
  end
end
