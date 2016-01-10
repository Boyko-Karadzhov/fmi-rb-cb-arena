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

  it 'should return true for a unique newGame' do
    name = 'game name'
    lobby = Lobby.new
    expect(lobby.new_game(GameOptions.new(name: name))).to be true
  end

  it 'should return false for a non-unique new_game' do
    name = 'game name'
    lobby = Lobby.new
    lobby.new_game(GameOptions.new(name: name))
    expect(lobby.new_game(GameOptions.new(name: name))).to be false
  end

  it 'should return list of players' do
    name = 'my player'
    lobby = Lobby.new
    lobby.sign_in name
    result = lobby.player_list

    expect(result).to be_kind_of(Array)
    expect(result.length).to eq(1)
    expect(result[0]).to eq(name)
  end

  it 'should return true for a unique player sign_in' do
    lobby = Lobby.new
    expect(lobby.sign_in('my player')).not_to be_nil
  end

  it 'should return false for a non-unique player sign_in' do
    name = 'my player'
    lobby = Lobby.new
    lobby.sign_in name
    expect(lobby.sign_in(name)).to be_nil
  end

  it 'should remove player from list on sign_out' do
    name = 'my player'
    lobby = Lobby.new
    lobby.sign_in name
    lobby.sign_out name
    expect(lobby.player_list).to be_empty
  end

  it 'should add a player to a game on join' do
    player_name = 'my man'
    game_name = 'my game'
    lobby = Lobby.new
    lobby.new_game(GameOptions.new(name: game_name))
    lobby.join player_name, game_name
    details = lobby.game_details game_name
    expect(details.players.length).to eq(1)
    expect(details.players[0]).to eq(player_name)
  end

  it 'should remove a player from a game on leave' do
    player1 = 'my man'
    player2 = 'other man'
    game_name = 'my game'
    lobby = Lobby.new
    lobby.new_game(GameOptions.new(name: game_name, size: 2))
    lobby.join player1, game_name
    lobby.join player2, game_name
    lobby.leave player1, game_name
    details = lobby.game_details game_name
    expect(details.players.length).to eq(1)
    expect(details.players[0]).to eq(player2)
  end

  it 'should remove the game when all players are gone' do
    player1 = 'my man'
    player2 = 'other man'
    game_name = 'my game'
    lobby = Lobby.new
    lobby.new_game(GameOptions.new(name: game_name, size: 2))
    lobby.join player1, game_name
    lobby.join player2, game_name
    lobby.leave player1, game_name
    lobby.leave player2, game_name
    expect(lobby.game_list).to be_empty
  end

  it 'should leave all games on signOut' do
    player1 = 'my man'
    player2 = 'other man'
    game_name = 'my game'
    lobby = Lobby.new
    lobby.sign_in player1
    lobby.new_game(GameOptions.new(name: game_name, size: 2))
    lobby.join player1, game_name
    lobby.join player2, game_name
    lobby.sign_out player1
    details = lobby.game_details game_name
    expect(details.players.length).to eq(1)
    expect(details.players[0]).to eq(player2)
  end
end
