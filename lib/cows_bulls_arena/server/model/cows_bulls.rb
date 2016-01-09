module CowsBullsArena
  module Server
    module Model
      module CowsBulls
        def self.new_secret
          %w(0 1 2 3 4 5 6 7 8 9).sample 4
        end
      end
    end
  end
end
