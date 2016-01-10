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
          @player_rounds = {}
        end

        def details
          OpenStruct.new(
            state: @state,
            round: @current_round,
            options: @options,
            players: @player_rounds.keys)
        end

        def join(player)
          if !@player_rounds.key?(player) && @state == State::WAITING
            @player_rounds[player] = []
            ensure_state
            true
          else
            false
          end
        end

        def leave(player)
          if @player_rounds.key? player
            @player_rounds.delete player
            ensure_state
            true
          else
            false
          end
        end

        module State
          WAITING = 'waiting'
          STARTED = 'started'
          FINISHED = 'finished'
        end

        private

        def ensure_state
          if @state == State::WAITING && @player_rounds.size == @options.size
            @state = State::STARTED
            start
          end

          @state = State::FINISHED if should_finish
          end_turn if all_players_are_done
        end

        def start
          @secret = @rules.new_secret
          round_timeout @current_round

          @end_turn_callback.call(details) if @end_turn_callback
        end

        def should_finish
          @player_rounds.empty? ||
            @current_round > @options.max_rounds ||
            all_players_guessed_right
        end

        def round_timeout(round)
          Thread.new do
            sleep @options.round_timeout
            end_turn if round == @current_round
          end
        end

        def end_turn
          @player_rounds.each_value do |rounds|
            rounds << nil if rounds.length < @current_round
          end

          @current_round += 1
          @state = State::FINISHED if
            @current_round > @options.max_rounds ||
            all_players_guessed_right

          round_timeout @current_round if @state == State::STARTED
          @end_turn_callback.call(details) if @end_turn_callback
        end

        def all_players_guessed_right
          @player_rounds.values.all? do |rounds|
            !rounds.empty? && rounds.any? { |r| !r.nil? && r.answer.bulls == 4 }
          end
        end

        def all_players_are_done
          @player_rounds.values.all? { |r| r.length == @current_round }
        end
      end
    end
  end
end
