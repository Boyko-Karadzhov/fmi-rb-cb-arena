require 'cows_bulls_arena/server/model/rules'

describe CowsBullsArena::Server::Model::Rules do
  Rules = CowsBullsArena::Server::Model::Rules

  it 'should generate a four digit secret' do
    secret = Rules.new_secret
    expect(secret.length).to eq(4)
  end

  it 'should evaluate questions correctly' do
    secret = %w(1 2 3 4)
    question = %w(1 2 3 4)
    result = Rules.evaluate secret, question
    expect(result[:cows]).to eq(0)
    expect(result[:bulls]).to eq(4)

    secret = %w(1 2 3 4)
    question = %w(5 6 7 8)
    result = Rules.evaluate secret, question
    expect(result[:cows]).to eq(0)
    expect(result[:bulls]).to eq(0)

    secret = %w(1 2 3 4)
    question = %w(1 3 2 4)
    result = Rules.evaluate secret, question
    expect(result[:cows]).to eq(2)
    expect(result[:bulls]).to eq(2)

    secret = %w(0 3 8 7)
    question = %w(0 1 2 3)
    result = Rules.evaluate secret, question
    expect(result[:cows]).to eq(1)
    expect(result[:bulls]).to eq(1)
  end

  it 'should return true for a valid question' do
    expect(Rules.validate_question(%w(1 2 3 4))).to be true
  end

  it 'should return false for non-array question' do
    expect(Rules.validate_question('I are question')).to be false
  end

  it 'should return false for question with repeating digits' do
    expect(Rules.validate_question(%w(1 2 3 3))).to be false
  end

  it 'should return false for question with wrong size' do
    expect(Rules.validate_question(%w(1))).to be false
  end
end
