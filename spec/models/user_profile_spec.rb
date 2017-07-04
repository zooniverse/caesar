require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  let(:workflow) { Workflow.create! project_id: 1 }
  let(:user_id) { 1 }

  def put(as_of, data)
    UserProfile.create!(project_id: workflow.project_id,
                        workflow_id: workflow.id,
                        user_id: user_id,
                        generator: 'gen',
                        as_of: as_of,
                        data: data)

  end

  describe '.lookup' do
    it 'returns the newest profile before the given time' do
      profile1 = put(5.hours.ago, {skill: 1})
      profile2 = put(1.hours.ago, {skill: 2})
      profile3 = put(5.hours.from_now, {skill: 3})

      expect(UserProfile.before(workflow.id, user_id, 'gen', 1.minute.ago)).to eq(profile2)
    end
  end
end
