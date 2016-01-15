require 'cows_bulls_arena/server/controller'

describe CowsBullsArena::Server::Controller do
  Controller = CowsBullsArena::Server::Controller

  class ClientMock
    attr_accessor :publications

    def initialize
      @publications = []
    end

    def publish(channel, data)
      @publications << { channel: channel, data: data }
    end
  end

  Controller.instance_methods(false).each do |action|
    next if action == :sign_in
    client = ClientMock.new
    controller = Controller.new
    next unless controller.method(action).parameters.length == 2
    client_id = '5'
    data = { 'ticket' => nil }
    controller.client = client

    it "should emit sign in fail on invalid ticket at #{action}." do
      controller.public_send action, client_id, data

      expect(client.publications.size).to eq(1)
      message = client.publications[0][:data]
      expect(message['action']).to eq('sign-in-fail')
    end
  end

  it 'should emit ticket on sign in' do
    client = ClientMock.new
    controller = Controller.new
    controller.client = client
    player = 'my man'
    client_id = '5'
    controller.sign_in client_id, player

    expect(client.publications.size).to eq(1)
    message = client.publications[0][:data]
    expect(message['action']).to eq('sign-in-success')
    expect(message['data']).not_to be_nil
    expect(message['data']['code']).not_to be_nil
    expect(message['data']['name']).to eq(player)
  end
end
