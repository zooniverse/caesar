require 'rails_helper'

RSpec.describe DescribeWorkflowWorker, type: :worker do
  let(:workflow) { create :workflow, project_id: 7 }
  let(:populated_workflow) { create :workflow, name: 'test name', project_name: 'test project name'}
  let(:contrived_workflow) { create :workflow, name: 'contrived_workflow', project_id: 7 }

  let(:panoptes) { double('PanoptesAdapter', workflow: {'display_name' => 'test workflow'}, project: {'display_name'=>'test project'}) }

  before do
    allow(Effects).to receive(:panoptes).and_return(panoptes)
  end

  it 'does nothing if the workflow already has information' do
    DescribeWorkflowWorker.new.perform(populated_workflow.id)
    expect(panoptes).not_to have_received(:workflow)
    expect(panoptes).not_to have_received(:project)
  end

  it 'does nothing if the workflow already has information' do
    contrived_workflow

    DescribeWorkflowWorker.new.perform(workflow.id)

    expect(panoptes).to have_received(:workflow).with(workflow.id)
    expect(panoptes).to have_received(:project).with(workflow.project_id)

    new_wf = Workflow.find(workflow.id)
    expect(new_wf.name).to eq('test workflow')
    expect(new_wf.project_name).to eq('test project')

    expect(Workflow.find(contrived_workflow.id).project_name).to eq('test project')
  end

end
