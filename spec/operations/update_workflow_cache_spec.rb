require 'rails_helper'

RSpec.describe UpdateWorkflowCache do
  it 'updates the cached rules for a workflow' do
    operation = described_class.new("id" => 1, "retirement" => {"nero" => {}})
    operation.perform

    expect(Workflow.count).to eq(1)
    expect(Workflow.first.retirement).to eq("nero" => {})
  end
end
