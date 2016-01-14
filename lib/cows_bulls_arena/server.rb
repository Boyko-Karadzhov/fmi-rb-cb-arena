require 'faye'
require 'thin'
require 'eventmachine'

module CowsBullsArena
  module Server
    def self.start
      Faye::WebSocket.load_adapter('thin')

      bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)

      Thread.new do
        sleep 1
        EM.run {
          bayeux.get_client().subscribe('/from-node') do |channel|
            p channel
          end


        }
      end

      Thin::Server.start('0.0.0.0', 3000, bayeux)
    end
  end
end
