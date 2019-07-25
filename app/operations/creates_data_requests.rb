class CreatesDataRequests < ApplicationOperation
  def call(obj, args)
    resource = args[:exportable_type].constantize.find(args[:exportable_id])

    data_request = DataRequest.new(
      exportable: resource,
      user_id: args[:user_id],
      subgroup: args[:subgroup],
      requested_data: args[:requested_data]
    )
    authorize(data_request, :create?)

    data_request.public = data_request.exportable.public_data?(data_request.requested_data)
    data_request.status = DataRequest.statuses[:pending]
    data_request.save!

    # sometimes the worker gets started before the save is persisted, which makes no sense
    # but it doesn't hurt to wait a few seconds for a job that is going to take a while to
    # run anyways
    DataRequestWorker.perform_in(2.seconds, data_request.id)
    data_request
  end
end
