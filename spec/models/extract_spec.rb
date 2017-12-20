require 'rails_helper'

RSpec.describe Extract, type: :model do

  it "should not fail to build the factory" do
    expect(build(:extract)).to be_valid
  end
end
