require 'faye'
require 'thin'
require 'eventmachine'

module CowsBullsArena
  module Server
    class CowsBullsServer
      def start
        Faye::WebSocket.load_adapter('thin')
        bayeux = Faye::RackAdapter.new mount: '/faye', timeout: 25

        Thread.new do
          sleep 1
          subscribe
        end

        Thin::Server.start '0.0.0.0', 3000, bayeux
      end

      private

      def subscribe
        EM.run do
          bayeux.get_client.subscribe('/server') do |channel|
            p channel
          end
        end
      end
    end

    def self.start
      CowsBullsServer.new.start
    end
  end
end
