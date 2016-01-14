require 'faye'
require 'facets'
require 'thin'
require 'eventmachine'
require 'cows_bulls_arena/server/controller'

module CowsBullsArena
  module Server
    Faye::WebSocket.load_adapter('thin')

    class CowsBullsServer
      def initialize
        @controller = CowsBullsArena::Server::Controller.new
        @bayeux = Faye::RackAdapter.new mount: '/faye', timeout: 25
      end

      def start
        EM.run do
          Signal.trap('INT')  { EventMachine.stop }
          Signal.trap('TERM') { EventMachine.stop }
          Rack::Handler.get('thin').run @bayeux, Port: 3000, signals: false
          subscribe
        end
      end

      private

      def subscribe
        proxy = { headers: { 'User-Agent' => 'Faye' } }
        endpoint = 'http://localhost:3000/faye'
        @controller.client = Faye::Client.new(endpoint, proxy: proxy)
        @controller.client.connect
        @controller.client.subscribe('/server') do |message|
          handle_message message
        end
      end

      def handle_message(message)
        action = message['action'].snakecase
        method = @controller.method(action) if @controller.respond_to?(action)
        method.call message['socketId'], message['data'] if method
      end
    end

    def self.start
      CowsBullsServer.new.start
    end
  end
end
