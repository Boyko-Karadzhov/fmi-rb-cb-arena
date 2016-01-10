require 'cows_bulls_arena/server/model/game'

describe CowsBullsArena::Server::Model::Game do
  Game = CowsBullsArena::Server::Model::Game
  GameOptions = CowsBullsArena::Server::Model::GameOptions

  it 'should initiate with "Waiting" state' do
    game = Game.new(GameOptions.new(name: 'some name'))
    expect(game.details.state).to eq(Game::State::WAITING)
  end

  it 'should be Started when game is full' do
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join 'my player'
    expect(game.details.state).to eq(Game::State::STARTED)
  end

  it 'should return true on player join' do
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    expect(game.join('my player')).to be true
  end

  it 'should return false on non-unique player join' do
    name = 'my player'
    game = Game.new(GameOptions.new(name: 'some name', size: 3))
    game.join name
    expect(game.join(name)).to be false
  end

  it 'should return false on full game player join' do
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join 'player1'
    expect(game.join('player2')).to be false
  end

  it 'should remove player on leave' do
    name = 'my player'
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join name
    game.leave name
    expect(game.details.players).to be_empty
  end

  it 'should be finished when last player leaves' do
    name = 'my player'
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join name
    game.leave name
    expect(game.details.state).to eq(Game::State::FINISHED)
  end
end
