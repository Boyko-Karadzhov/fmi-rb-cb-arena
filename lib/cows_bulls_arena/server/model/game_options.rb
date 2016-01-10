module CowsBullsArena
  module Server
    module Model
      class GameOptions
        attr_accessor :name, :size, :max_rounds, :round_timeout

        def initialize(options = {})
          @name = options[:name] || nil
          @size = options[:size] || 1
          @max_rounds = options[:max_rounds] || 20
          @round_timeout = options[:round_timeout] || 2 * 60
        end
      end
    end
  end
end
