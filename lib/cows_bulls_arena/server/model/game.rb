require 'ostruct'
require 'cows_bulls_arena/server/model/game_options'
require 'cows_bulls_arena/server/model/rules'

module CowsBullsArena
  module Server
    module Model
      class Game
        def initialize(options, end_turn_callback = nil, rules = nil)
          @state = State::WAITING
          @options = options
          @secret = nil
          @current_round = 1
          @end_turn_callback = end_turn_callback
          @rules = rules || CowsBullsArena::Server::Model::Rules
        end

        def details
          OpenStruct.new(
            state: @state,
            round: @current_round,
            options: @options)
        end

        module State
          WAITING = 'waiting'
          STARTED = 'started'
          FINISHED = 'finished'
        end
      end
    end
  end
end
