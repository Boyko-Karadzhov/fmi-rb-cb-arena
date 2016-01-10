require 'cows_bulls_arena/server/model/game'

describe CowsBullsArena::Server::Model::Game do
  Game = CowsBullsArena::Server::Model::Game
  GameOptions = CowsBullsArena::Server::Model::GameOptions

  it 'should initiate with "Waiting" state' do
    game = Game.new(GameOptions.new(name: 'some name'))
    expect(game.details.state).to eq(Game::State::WAITING)
  end
end
