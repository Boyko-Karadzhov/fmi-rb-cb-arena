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
      end
    end
  end
end
