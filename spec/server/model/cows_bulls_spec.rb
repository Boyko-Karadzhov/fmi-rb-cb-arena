require 'cows_bulls_arena/server/model/cows_bulls'

describe CowsBullsArena::Server::Model::CowsBulls do
  cows_bulls = CowsBullsArena::Server::Model::CowsBulls

  it 'should generate a four digit secret' do
    secret = cows_bulls.new_secret
    expect(secret.length).to eq(4)
  end
end
