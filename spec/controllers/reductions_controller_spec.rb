require 'spec_helper'
require 'ostruct'

describe ReductionsController, :type => :controller do
  let(:reductions) {
    [
      Reduction.create!(workflow_id: 1234, subject_id: 5678, reducer_key: 'r', data: '1'),
      Reduction.create!(workflow_id: 1234, subject_id: 5678, reducer_key: 's', data: '2'),
      Reduction.create!(workflow_id: 1234, subject_id: 6789, reducer_key: 'r', data: '3')
    ]
  }

  def tamper_auth
    # i can do what i want
    #
    # --ron swanson
    allow_any_instance_of(ReductionsController).to receive(:authenticated?).and_return(true)
    # allow_any_instance_of(ReductionsController).to receive(:authorized?).and_return(true)
    allow_any_instance_of(Credential).to receive(:logged_in?).and_return(true)
    allow_any_instance_of(Credential).to receive(:expired?).and_return(false)
    allow_any_instance_of(Credential).to receive(:admin?).and_return(true)
  end

  before do
    Subject.create! id: 5678
    Subject.create! id: 6789
    Workflow.create! id: 1234, project_id: 12
  end

  after do
    Reduction.delete_all
    Subject.delete_all
    Workflow.delete_all
  end

  describe '#index' do
    it 'returns only the requested reductions' do
      tamper_auth
      reductions

      response = get :index, params: { workflow_id: 1234, reducer_key: 'r', subject_id: 5678 }
      results = JSON.parse(response.body)

      expect(response).to be_success
      expect(results.size).to be(1)
      expect(results[0]).to include("reducer_key" => "r", "subject_id" => 5678)
      expect(results[0]).not_to include("reducer_key" => "s")
      expect(results[0]).not_to include("subject_id" => 6789)
    end
  end

  describe '#update' do
    it 'updates an existing reduction' do
      r = reductions
      tamper_auth

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'r')
      )

      post :update, params: {
        workflow_id: 1234,
        reducer_key: 'r',
        reduction: {
          subject_id: 5678,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = Reduction.find_by(
        workflow_id: 1234,
        reducer_key: 'r',
        subject_id: 5678
      )

      expect(Reduction.count).to eq(3)
      expect(updated.id).to eq(r[0].id)
      expect(updated.data).to eq("blah" => "10")
    end

    it 'creates new reductions if needed' do
      reductions
      tamper_auth

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'q')
      )

      post :update, params: {
        workflow_id: 1234,
        reducer_key: 'q',
        reduction: {
          subject_id: 5678,
          subgroup: '_default',
          data: { blah: 10 }
        }
      }

      updated = Reduction.find_by(
        workflow_id: 1234,
        reducer_key: 'q',
        subject_id: 5678
      )

      expect(Reduction.count).to eq(4)
      expect(updated.data).to eq("blah" => "10")
    end
  end

  describe '#nested_update' do
    it 'creates multiple reductions from the data' do
      tamper_auth

      #we don't have any real reducers configured, so work around that
      allow_any_instance_of(ReductionsController).to receive(:reducer).and_return(
        OpenStruct.new(key: 'q')
      )

      post :nested_update, params: {
        workflow_id: 1234,
        reducer_key: 'q',
        reduction: {
          subject_id: 5678,
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
