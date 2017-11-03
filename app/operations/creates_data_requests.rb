class CreatesDataRequests
  def self.call(obj, args, ctx)
    credential = ctx[:credential]

    data_request = DataRequest.new(
      workflow_id: args[:workflow_id],
      user_id: args[:user_id],
      subgroup: args[:subgroup],
      requested_data: args[:requested_data]
    )

    Pundit.authorize(credential, data_request, :create?)

    data_request.status = DataRequest.statuses[:pending]
    data_request.url = nil
    data_request.save!

    DataRequestWorker.perform_async(data_request.workflow_id)
    data_request
  end
end
