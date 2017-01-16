require 'rails_helper'

RSpec.describe UpdateWorkflowCache do
  it 'processes unconfigured workflows' do
    operation = described_class.new("id" => 1, "retirement" => {})
    operation.perform

    expect(Workflow.count).to eq(1)
    expect(Workflow.first.extractors_config).to eq({})
    expect(Workflow.first.reducers_config).to eq({})
    expect(Workflow.first.rules_config).to eq([])
  end

  it 'processes workflows without rules' do
    operation = described_class.new("id" => 1, "retirement" => {"nero" => {}})
    operation.perform

    expect(Workflow.count).to eq(1)
    expect(Workflow.first.extractors_config).to eq({})
    expect(Workflow.first.reducers_config).to eq({})
    expect(Workflow.first.rules_config).to eq([])
  end

  it 'processes configured workflows' do
    extractors_config = {"s" => {"type" => "survey", "task_key" => "T0"}}
    reducers_config = {"s" => {"type" => "simple_survey"}}
    rules_config = [
      {
        "if" => ["gte", ["lookup", "survey-total-VHCL"], ["const", 1]],
        "then" => [{"action" => "retire_subject", "reason" => "flagged"}]
      }
    ]

    operation = described_class.new("id" => 1,
                                    "retirement" => {
                                      "nero" => {
                                        "extractors" => extractors_config,
                                        "reducers" => reducers_config,
                                        "rules" => rules_config,
                                      }
                                    })
    operation.perform

    expect(Workflow.count).to eq(1)
    expect(Workflow.first.extractors_config).to eq(extractors_config)
    expect(Workflow.first.reducers_config).to eq(reducers_config)
    expect(Workflow.first.rules_config).to eq(rules_config)
  end
end
