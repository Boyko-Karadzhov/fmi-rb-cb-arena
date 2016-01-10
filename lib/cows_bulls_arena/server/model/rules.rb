require 'ostruct'

module CowsBullsArena
  module Server
    module Model
      module Rules
        ALLOWED_CHARACTERS = %w(0 1 2 3 4 5 6 7 8 9)

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

          OpenStruct.new(bulls: bulls, cows: cows)
        end

        def self.validate_question(question)
          question.is_a?(Array) && question.length == 4 &&
            question.all? { |c| ALLOWED_CHARACTERS.include? c } &&
            question.uniq.length == question.length
        end
      end
    end
  end
end
