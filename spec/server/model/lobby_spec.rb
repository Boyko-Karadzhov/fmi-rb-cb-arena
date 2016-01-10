require 'cows_bulls_arena/server/model/lobby'

describe CowsBullsArena::Server::Model::Lobby do
  Lobby = CowsBullsArena::Server::Model::Lobby
  GameOptions = CowsBullsArena::Server::Model::GameOptions

  it 'should return list of games' do
    name = 'game name'
    lobby = Lobby.new
    lobby.new_game(GameOptions.new(name: name))
    result = lobby.game_list

    expect(result).to be_kind_of(Array)
    expect(result.length).to eq(1)
    expect(result[0]).to eq(name)
  end
end
