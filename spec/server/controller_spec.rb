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

  class ControllerMock < Controller
    def initialize(lobby = nil)
      super

      @client = ClientMock.new
    end

    def validate(*_)
      true
    end
  end

  def define_singleton_method_by_proc(obj, name, block)
    metaclass = class << obj; self; end
    metaclass.send(:define_method, name, block)
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
    controller = Controller.new
    client = ClientMock.new
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

  it 'should emit game list on lobby_game_list' do
    game_list = 'mah list'
    client_id = '5'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :game_list, proc { |*_| game_list }
    controller = ControllerMock.new lobby

    controller.lobby_game_list client_id, nil

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('lobby-game-list')
    expect(message['data']).to eq(game_list)
  end

  it 'should emit join on new_game if it\'s successful' do
    game = 'mah game'
    player = 'my man'
    client_id = '5'
    lobby = Lobby.new
    controller = ControllerMock.new lobby
    controller.new_game(
      client_id,
      'ticket' => { 'name' => player },
      'options' => {
        'name' => game,
        'size' => 1,
        'max_rounds' => 20,
        'round_timeout' => 100
      }
    )

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('join')
    expect(message['data']).to eq(game)
  end

  it 'should emit game list on new_game if it\'s successful' do
    game = 'mah game'
    player1 = 'my man'
    player2 = 'other man'
    game_list = 'mah list'
    client_id = '5'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :game_list, proc { |*_| game_list }
    controller = ControllerMock.new lobby

    controller.sign_in client_id, player1
    controller.new_game(
      client_id,
      'ticket' => { 'name' => player2 },
      'options' => {
        'name' => game,
        'size' => 1,
        'max_rounds' => 20,
        'round_timeout' => 100
      }
    )

    expect(controller.client.publications.size).to eq(3)
    message = controller.client.publications[1][:data]
    expect(message['action']).to eq('lobby-game-list')
    expect(message['data']).to eq(game_list)
  end

  it 'should emit new-game-fail on new_game if it\'s invalid' do
    client_id = '5'
    game = 'mah game'
    player = 'my man'
    lobby = Lobby.new
    controller = ControllerMock.new lobby

    controller.new_game(
      client_id,
      'ticket' => { 'name' => player },
      'options' => {
        'name' => game,
        'size' => 0,
        'max_rounds' => 20,
        'round_timeout' => 100
      }
    )

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('new-game-fail')
  end

  it 'should emit join on successful join' do
    client_id = '5'
    game = 'mah game'
    player = 'my man'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :join, proc { |*_| true }
    controller = ControllerMock.new lobby

    controller.join(
      client_id,
      'ticket' => { 'name' => player },
      'game' => game
    )

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('join')
    expect(message['data']).to eq(game)
  end

  it 'should emit lobby-fail on unsuccessful join' do
    client_id = '5'
    game = 'mah game'
    player = 'my man'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :join, proc { |*_| false }
    controller = ControllerMock.new lobby

    controller.join(
      client_id,
      'ticket' => { 'name' => player },
      'game' => game
    )

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('lobby-fail')
  end

  it 'should emit game-details on valid game_details' do
    client_id = '5'
    game = 'mah game'
    details = 'details'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :game_details, proc { |*_| details }
    controller = ControllerMock.new lobby

    controller.game_details client_id, 'game' => game

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('game-details')
    expect(message['data']).to eq(details)
  end

  it 'should emit lobby-fail on invalid game-details' do
    client_id = '5'
    game = 'mah game'
    lobby = Lobby.new
    define_singleton_method_by_proc lobby, :game_details, proc { |*_| nil }
    controller = ControllerMock.new lobby

    controller.game_details client_id, 'game' => game

    expect(controller.client.publications.size).to eq(1)
    message = controller.client.publications[0][:data]
    expect(message['action']).to eq('lobby-fail')
  end

  it 'should broadcast game details to players when new player joins' do
    game = 'mah game'
    player1 = 'my man'
    player2 = 'other man'
    client_id = '5'
    lobby = Lobby.new
    controller = ControllerMock.new lobby
    controller.sign_in client_id, player1

    controller.new_game(
      client_id,
      'ticket' => { 'name' => player1 },
      'options' => {
        'name' => game,
        'size' => 2,
        'max_rounds' => 20,
        'round_timeout' => 100
      }
    )

    controller.join(
      client_id,
      'ticket' => { 'name' => player2 },
      'game' => game
    )

    expect(controller.client.publications.size).to eq(7)
    message = controller.client.publications[3][:data]
    expect(message['action']).to eq('game-details')
  end
end
