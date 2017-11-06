class CreatesDataRequests < ApplicationOperation
  def call(obj, args)
    data_request = DataRequest.new(
      workflow_id: args[:workflow_id],
      user_id: args[:user_id],
      subgroup: args[:subgroup],
      requested_data: args[:requested_data]
    )

    authorize(data_request, :create?)

    data_request.public = data_request.workflow.public_data?(data_request.requested_data)
    data_request.status = DataRequest.statuses[:pending]
    data_request.url = nil
    data_request.save!

    DataRequestWorker.perform_async(data_request.workflow_id)
    data_request
  end
end
