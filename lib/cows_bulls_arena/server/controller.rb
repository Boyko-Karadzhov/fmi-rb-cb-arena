require 'cows_bulls_arena/server/model'

module CowsBullsArena
  module Server
    class Controller
      attr_accessor :client

      def initialize
        @client = nil
        @active_sessions = {}
        @lobby = CowsBullsArena::Server::Model::Lobby.new
      end

      def sign_in(client_id, data)
        return if data.nil? || data.strip.empty?

        name = data.strip
        result = @lobby.sign_in name
        if result
          @active_sessions[name] = client_id
          ticket = { 'name' => name, 'code' => result.code }
          send(client_id, 'sign-in-success', ticket)
        else
          fail_sign_in client_id
        end
      end

      private

      def send(client_id, action, data = nil)
        @client.publish(
          '/client',
          'target' => client_id,
          'action' => action,
          'data' => data) unless @client.nil?
      end

      def fail_sign_in(client_id)
        send client_id, 'sign-in-fail'
      end
    end
  end
end
