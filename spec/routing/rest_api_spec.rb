require 'spec_helper'

describe 'REST API routes' do
  it 'routes pre-subject/user reduction api' do
    expect(get: '/workflows/1/reducers/swap/reductions').to route_to(
      controller: 'subject_reductions',
      action: 'index',
      workflow_id: '1',
      reducer_key: 'swap'
    )
    expect(get: '/workflows/1/subjects/2/reductions').to route_to(
      controller: 'subject_reductions',
      action: 'index',
      workflow_id: '1',
      subject_id: '2'
    )
    expect(put: '/workflows/1/reducers/swap/reductions').to route_to(
      controller: 'subject_reductions',
      action: 'update',
      workflow_id: '1',
      reducer_key: 'swap'
    )
  end
end
