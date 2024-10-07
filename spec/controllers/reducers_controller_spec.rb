require 'spec_helper'

describe ReducersController, :type => :controller do
  let(:workflow) { create :workflow }

  let(:reducer) do
    create :external_reducer, reducible: workflow
  end

  context 'as a permissioned user' do
    before{ fake_session admin: false, project_ids: [workflow.project_id], logged_in: true }

    describe '#destroy' do
      it 'lets a user delete reducers if they own the workflow' do
        r2 = create :external_reducer, reducible: workflow
        response = delete :destroy, params: { id: r2.id, workflow_id: workflow.id }, format: :json

        expect(response.status).to eq(204)
        expect(Reducer.find_by_id(r2.id)).to be(nil)
      end

      it 'does not let a user delete reducers if they do not own the workflow' do
        other_workflow = create :workflow, project_id: workflow.project_id + 1
        r2 = create :external_reducer, reducible: other_workflow
        response = delete :destroy, params: { id: r2.id, workflow_id: other_workflow.id }, format: :json

        expect(response.status).to eq(404)
        expect(Reducer.find_by_id(r2.id)).not_to be(nil)
      end
    end
  end

  context 'as an admin' do
    before { fake_session admin: true }

    describe '#index' do
      it 'lists reducers for a workflow' do
        reducers = [create(:external_reducer, reducible: workflow),
                    create(:stats_reducer, reducible: workflow)]
        get :index, params: {workflow_id: workflow.id}, format: :json
        expect(json_response.map { |i| i["id"] }).to match_array(reducers.map(&:id))
      end

      it 'returns empty list when there are no reducers' do
        get :index, params: {workflow_id: workflow.id}, format: :json
        expect(json_response).to eq([])
      end
    end

    describe '#show' do
      it 'returns a reducer' do
        get :show, params: {workflow_id: workflow.id, id: reducer.id}, format: :json
        expect(response.body).to eq(reducer.to_json)
      end
    end

    describe '#new' do
      it 'renders when given a type' do
        get :new, params: {workflow_id: workflow.id, type: 'external'}
        expect(response.status).to eq(200)
      end
    end

    describe '#edit' do
      it 'renders' do
        get :edit, params: {workflow_id: workflow.id, id: reducer.id}
        expect(response.status).to eq(200)
      end
    end

    describe '#create' do
      let(:reducer_params) { { key: 'a', type: 'external', url: 'https://example.org' } }
      let(:nested_reducer_params) {
        {
          key: 'a',
          type: 'external',
          config: { url: 'https://example.org' },
          filters: { extractor_keys: ['test'] }
        }
      }
      it 'creates a new reducer' do
        post :create, params: {workflow_id: workflow.id, reducer: reducer_params}
        expect(response).to redirect_to(workflow_path(workflow, anchor: 'reducers'))
        expect(workflow.reducers.count).to eq(1)
        expect(workflow.reducers.first.url).to eq('https://example.org')
      end

      it 'handles properties on nested objects' do
        post :create, params: {
          workflow_id: workflow.id,
          reducer: nested_reducer_params
        }, format: :json

        expect(response).to have_http_status(:ok)
        expect(workflow.reducers.count).to eq(1)
        expect(workflow.reducers.first.filters['extractor_keys']).to eq(['test'])
      end

      it 'jsonifies extractor_keys' do
        post :create, params: {
          workflow_id: workflow.id,
          reducer: nested_reducer_params
        }, format: :json

        expect(response).to have_http_status(:ok)
        expect(workflow.reducers.count).to eq(1)
        expect(workflow.reducers.first.filters['extractor_keys']).to eq(['test'])
      end

      it 'renders form on errors' do
        post :create, params: { workflow_id: workflow.id, reducer: { key: nil, type: 'external' } }
        expect(response.status).to eq(200)
      end

      it 'renders 422 on error and Accept headers is application/json' do
        request.headers['Accept'] = 'application/json'
        post :create, params: { workflow_id: workflow.id, reducer: { key: nil, type: 'external' } }
        expect(response.status).to eq(422)
      end

      it 'renders 422 on non-unique/db key error' do
        post :create, params: { workflow_id: workflow.id, reducer: { key: reducer.key, type: 'external' } }
        expect(response.status).to eq(422)
      end

      it 'renders 422 on unknown reducer type' do
        nested_reducer_params[:type] = ''
        post :create, params: {
          workflow_id: workflow.id,
          reducer: nested_reducer_params
        }, format: :json
        expect(response.status).to eq(422)
      end
    end
    describe '#update' do
      it 'updates the specified reducer' do
        put :update, params: {workflow_id: workflow.id,
                              id: reducer.id,
                              reducer: {url: 'https://example.org/2'}}
        expect(response).to redirect_to(workflow_path(workflow, anchor: 'reducers'))
        expect(workflow.reducers.first.url).to eq('https://example.org/2')
      end

      it 'renders form on errors' do
        put :update, params: {workflow_id: workflow.id,
                              id: reducer.id,
                              reducer: {key: nil, type: 'external'}}
        expect(response.status).to eq(200)
      end

      context 'when topic is reduce_by_subject' do
        it 'sets subject_reducer_keys to nil' do
          put :update, params: {
            workflow_id: workflow.id,
            id: reducer.id,
            reducer: {
              url: 'https://example.org/2',
              user_reducer_keys: 'user_reducer_keys_value',
              subject_reducer_keys: 'subject_reducer_keys',
              topic: 'reduce_by_subject'
            },
          }

          reducer.reload
          expect(reducer.subject_reducer_keys).to be_nil
          expect(reducer.user_reducer_keys).to eq('user_reducer_keys_value')
        end
      end

      context 'when topic is not reduce_by_subject' do
        it 'sets user_reducer_keys to nil' do
          put :update, params: {
            workflow_id: workflow.id,
            id: reducer.id,
            reducer: {
              url: 'https://example.org/2',
              user_reducer_keys: 'user_reducer_keys_value',
              subject_reducer_keys: 'subject_reducer_keys_value',
              topic: 'reduce_by_user'
            }
          }

          reducer.reload
          expect(reducer.subject_reducer_keys).to eq('subject_reducer_keys_value')
          expect(reducer.user_reducer_keys).to be_nil
        end
      end
    end
  end
end
