require 'securerandom'

module CowsBullsArena
  module Server
    module Model
      class Lobby
        class PlayerRecord
          ACTIVITY_TIMEOUT = 10 * 60
          private_constant :ACTIVITY_TIMEOUT

          attr_accessor :code

          def initialize
            @code = SecureRandom.uuid
            @seconds_left = ACTIVITY_TIMEOUT
          end

          def timed_out?
            @seconds_left <= 0
          end

          def step
            @seconds_left -= 1
          end
        end
      end
    end
  end
end
