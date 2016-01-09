module CowsBullsArena
  module Server
    module Model
      module CowsBulls
        ALLOWED_CHARACTERS = %w(0 1 2 3 4 5 6 7 8 9)

        class Result
          attr_reader :bulls, :cows

          def initialize(bulls, cows)
            @bulls = bulls
            @cows = cows
          end
        end

        def self.new_secret
          ALLOWED_CHARACTERS.sample 4
        end

        def self.evaluate(secret, question)
          bulls = cows = 0
          question.each_index do |i|
            idx = secret.index(question[i])
            bulls += 1 if idx == i
            cows += 1 if idx != i && !idx.nil?
          end

          Result.new(bulls, cows)
        end

        def self.validate_question(question)
          question.is_a?(Array) && question.length == 4 &&
            question.all? { |c| ALLOWED_CHARACTERS.include?(c) } &&
            question.uniq.length == question.length
        end
      end
    end
  end
end
