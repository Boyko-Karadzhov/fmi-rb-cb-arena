require 'cows_bulls_arena/server/model/game'

module CowsBullsArena
  module Server
    module Model
      class Lobby
        PLAYER_ACTIVITY_TIMEOUT = 10 * 60
        private_constant :PLAYER_ACTIVITY_TIMEOUT

        def initialize
          @games = {}
          @players = {}
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
      end
    end
  end
end
