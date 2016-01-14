require 'ostruct'
require 'cows_bulls_arena/server/model/game_options'
require 'cows_bulls_arena/server/model/game-state'
require 'cows_bulls_arena/server/model/rules'

module CowsBullsArena
  module Server
    module Model
      class Game
        def initialize(options, end_turn_callback = nil, rules = nil)
          @state = State::WAITING
          @options = options
          @current_round = 1
          @end_turn_callback = end_turn_callback
          @rules = rules || CowsBullsArena::Server::Model::Rules
          @player_rounds = {}
        end

        def details
          OpenStruct.new(
            state: @state,
            round: @current_round,
            options: @options,
            players: @player_rounds.keys,
            winner: winner)
        end

        def join(player)
          return false if
            @player_rounds.key?(player) || @state != State::WAITING

          @player_rounds[player] = []
          ensure_state
          true
        end

        def leave(player)
          return false unless @player_rounds.key? player

          @player_rounds.delete player
          ensure_state
          true
        end

        def ask(player, question)
          return nil unless can_ask? player, question

          @player_rounds[player] << OpenStruct.new(
            round: @current_round,
            time: Time.now.to_i,
            question: question,
            answer: @rules.evaluate(@secret, question)
          )

          ensure_state
          @player_rounds[player].last
        end

        private

        def can_ask?(player, question)
          @state == State::STARTED &&
            @rules.validate_question(question) && @player_rounds.key?(player) &&
            @player_rounds[player].length < @current_round
        end

        def ensure_state
          if @state == State::WAITING && @player_rounds.size == @options.size
            @state = State::STARTED
            start
          end

          @state = State::FINISHED if should_finish
          end_turn if
            @player_rounds.values.all? { |r| r.length == @current_round }
        end

        def start
          @secret = @rules.new_secret
          round_timeout @current_round

          @end_turn_callback.call(details) if @end_turn_callback
        end

        def should_finish
          @player_rounds.empty? ||
            @current_round > @options.max_rounds || all_players_guessed_right
        end

        def round_timeout(round)
          Thread.new do
            sleep @options.round_timeout
            end_turn if round == @current_round
          end
        end

        def end_turn
          @player_rounds.each_value { |r| r << nil if r.size < @current_round }

          @current_round += 1
          @state = State::FINISHED if
            @current_round > @options.max_rounds || all_players_guessed_right

          round_timeout @current_round if @state == State::STARTED
          @end_turn_callback.call(details) if @end_turn_callback
        end

        def all_players_guessed_right
          @player_rounds.values.all? do |rounds|
            !rounds.empty? && rounds.any? { |r| !r.nil? && r.answer.bulls == 4 }
          end
        end

        def winner
          return nil if @state != State::FINISHED
          current = nil
          @player_rounds
            .each_key { |p| current = p if finished_better? p, current }

          current
        end

        def finished_better?(player1, player2)
          !last_round(player1).nil? && (player2.nil? ||
              last_round(player1).round < last_round(player2).round ||
              last_round(player1).time < last_round(player2).time)
        end

        def last_round(player)
          @player_rounds[player]
            .reverse
            .find { |r| !r.nil? && r.answer.bulls == 4 }
        end
      end
    end
  end
end
