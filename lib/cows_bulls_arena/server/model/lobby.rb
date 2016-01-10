require 'cows_bulls_arena/server/model/game'
require 'cows_bulls_arena/server/model/lobby-player_record'

module CowsBullsArena
  module Server
    module Model
      class Lobby
        def initialize
          @games = {}
          @players = {}

          Thread.new do
            @players.each { |_n, p| p.step }
            @players.delete_if { |_n, p| p.timed_out? }
          end
        end

        def new_game(options, end_turn_timeout = nil)
          return false if
            options.name.nil? ||
            options.name == '' ||
            @games.key?(options.name)

          @games[options.name] = Game.new(options, end_turn_timeout)
          true
        end

        def game_list
          @games.select { |_n, g| g.details.state == Game::State::WAITING }.keys
        end

        def player_list
          @players.keys
        end

        def sign_in(name)
          return nil if @players.key? name

          @players[name] = PlayerRecord.new
        end

        def sign_out(name)
          return unless @players.key? name

          @games.each { |_n, g| g.leave(name) }
          @players.delete name
        end

        def validate_player(name, code)
          valid_pair = @players.key?(name) && @players[name].code == code
          @players[name].reset if valid_pair

          valid_pair
        end

        def join(player, game)
          @games.key?(game) && @games[game].join(player)
        end

        def leave(player, game)
          result = @games.key?(game) && @games[game].leave(player)
          ensure_game game
          result
        end

        def ask(player, game, question)
          return nil unless @games.key?(game)

          @games[game].ask player, question
        end

        def game_details(game)
          (@games.key?(game) && @games[game].details) || nil
        end

        private

        def ensure_game(game)
          @games.delete(game) if
            @games.key?(game) &&
            @games[game].details.players.empty?
        end
      end
    end
  end
end
