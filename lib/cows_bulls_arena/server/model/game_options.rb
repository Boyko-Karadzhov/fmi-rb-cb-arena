module CowsBullsArena
  module Server
    module Model
      class GameOptions
        attr_accessor :name, :size, :max_rounds, :round_timeout

        def initialize(options = {})
          @name = options[:name] || options['name']
          @name = @name.strip unless @name.nil?

          @size = options[:size] || options['size'] || 1
          @size = @size.to_i

          @max_rounds = options[:max_rounds] || options['max-rounds'] || 20
          @max_rounds = @max_rounds.to_i

          @round_timeout = options[:round_timeout] || options['round-timeout']
          @round_timeout = @round_timeout.to_i unless @round_timeout.nil?
          @round_timeout = 2 * 60 if @round_timeout.nil?
        end

        def valid?
          !@name.nil? && !@name.empty? && @size >= 1 && @max_rounds >= 1 &&
            @round_timeout >= 10 && @round_timeout <= 590
        end

        def to_h
          {
            name: @name,
            size: @size,
            maxRounds: @max_rounds,
            roundTimeout: @round_timeout
          }
        end
      end
    end
  end
end
