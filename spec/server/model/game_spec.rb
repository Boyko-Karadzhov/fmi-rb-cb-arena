require 'cows_bulls_arena/server/model/game'
require 'cows_bulls_arena/server/model/rules'

describe CowsBullsArena::Server::Model::Game do
  Game = CowsBullsArena::Server::Model::Game
  GameOptions = CowsBullsArena::Server::Model::GameOptions
  Rules = CowsBullsArena::Server::Model::Rules

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

  it 'should return false when asked on a non-started game' do
    player = 'my man'
    game = Game.new(GameOptions.new(name: 'some name', size: 2))
    game.join player
    expect(game.ask(player, %w(1 2 3 4))).to be_nil
  end

  it 'should return false when asked out of order' do
    player1 = 'my man'
    player2 = 'other man'
    question = %w(1 2 3 4)
    game = Game.new(GameOptions.new(name: 'some name', size: 2))
    game.join player1
    game.join player2
    game.ask player1, question
    expect(game.ask(player1, question)).to be_nil
  end

  it 'should return true when asked correctly' do
    player1 = 'my man'
    question = %w(1 2 3 4)
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join player1
    expect(game.ask(player1, question)).not_to be_nil
  end

  it 'should proceed to next turn when all players are done asking' do
    player1 = 'my man'
    player2 = 'other man'
    question = %w(1 2 3 4)
    game = Game.new(GameOptions.new(name: 'some name', size: 2))
    game.join player1
    game.join player2
    game.ask player1, question
    game.ask player2, question
    expect(game.details.round).to eq(2)
  end

  it 'should finish when rounds are over the max' do
    player1 = 'my man'
    question = %w(1 2 3 4)
    game = Game.new(GameOptions.new(name: 'some name', max_rounds: 1))
    game.join player1
    game.ask player1, question
    expect(game.details.state).to eq(Game::State::FINISHED)
  end

  it 'should finish when all players guess the secret' do
    player1 = 'my man'
    player2 = 'other man'
    question = %w(1 2 3 4)
    rules_mock = Rules.clone
    rules_mock.define_singleton_method :new_secret do
      question
    end

    game = Game.new(
      GameOptions.new(name: 'some name', size: 1),
      nil,
      rules_mock)

    game.join player1
    game.join player2
    game.ask player1, question
    game.ask player2, question
    expect(game.details.state).to eq(Game::State::FINISHED)
  end

  it 'should return null for winner while game is not finished' do
    game = Game.new(GameOptions.new(name: 'some name', size: 1))
    game.join 'my player'
    expect(game.details.winner).to be_nil
  end

  it 'should return for winner the player which got the answer first' do
    player1 = 'my man'
    player2 = 'other man'
    question = %w(1 2 3 4)
    rules_mock = Rules.clone
    rules_mock.define_singleton_method :new_secret do
      question
    end

    game = Game.new(
      GameOptions.new(name: 'some name', size: 2),
      nil,
      rules_mock)

    game.join player1
    game.join player2
    game.ask player1, %w(0 1 2 3)
    game.ask player2, question
    game.ask player1, question
    expect(game.details.winner).to eq(player2)
  end
end
