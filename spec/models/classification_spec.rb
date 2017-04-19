require 'spec_helper'

describe Classification do
  describe '#user_id' do
    it 'returns the user id' do
      classification = Classification.new("links" => {"user" => "123"})
      expect(classification.user_id).to eq(123)
    end

    it 'returns nil if no user id' do
      classification = Classification.new("links" => {"user" => nil})
      expect(classification.user_id).to be_nil
    end

    it 'returns nil if user not linked' do
      classification = Classification.new("links" => {})
      expect(classification.user_id).to be_nil
    end
  end
end
