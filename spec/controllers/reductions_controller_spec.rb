require 'spec_helper'
require 'ostruct'

describe ReductionsController, :type => :controller do
    let(:workflow) { create :workflow }
    let(:subject1) { create :subject }
    let(:subject2) { create :subject }
    let(:reductions) {
    [
      create(:reduction, workflow: workflow, subject: subject1, reducer_key: 'r', data: '1'),
      create(:reduction, workflow: workflow, subject: subject1, reducer_key: 's', data: '2'),
      create(:reduction, workflow: workflow, subject: subject2, reducer_key: 'r', data: '3')
    ]
  }

  before { fake_session(admin: true) }

  describe '#index' do
    it 'returns only the requested reductions' do
      reductions

      response = get :index, params: { workflow_id: workflow.id, reducer_key: 'r', subject_id: subject1.id }
      results = JSON.parse(response.body)

      expect(response).to be_success
      expect(results.size).to be(1)
      expect(results[0]).to include("reducer_key" => "r", "subject_id" => subject1.id)
      expect(results[0]).not_to include("reducer_key" => "s")
      expect(results[0]).not_to include("subject_id" => subject2.id)
    end
  end

  describe '#update' do
    it 'updates an existing reduction' do
      r = reductions

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'r')
      )

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: 'r',
        reduction: {
          subject_id: subject1.id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = Reduction.find_by(
        workflow_id: workflow.id,
        reducer_key: 'r',
        subject_id: subject1.id
      )

      expect(Reduction.count).to eq(3)
      expect(updated.id).to eq(r[0].id)
      expect(updated.data).to eq("blah" => "10")
    end

    it 'creates new reductions if needed' do
      reductions

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'q')
      )

      post :update, params: {
        workflow_id: workflow.id,
        reducer_key: 'q',
        reduction: {
          subject_id: subject1.id,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = Reduction.find_by(
        workflow_id: workflow.id,
        reducer_key: 'q',
        subject_id: subject1.id
      )

      expect(Reduction.count).to eq(4)
      expect(updated.data).to eq("blah" => "10")
    end
  end

  describe '#nested_update' do
    it 'creates multiple reductions from the data' do

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'q')
      )

      post :nested_update, params: {
        workflow_id: workflow.id,
        reducer_key: 'q',
        reduction: {
          subject_id: subject1.id,
          data: {
            group1: {
              blah: 11
            },
            group2: {
              blah: 11
            }
          }
        }
      }

      expect(Reduction.count).to eq(2)
      expect(Reduction.exists?(subgroup: 'group1')).to be(true)
      expect(Reduction.exists?(subgroup: 'group2')).to be(true)
      expect(Reduction.exists?(subgroup: '_default')).to be(false)
    end
  end
end
