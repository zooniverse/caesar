class CreatesDataRequests < ApplicationOperation
  def call(obj, args)
    data_request = DataRequest.new(
      exportable: exportable,
      user_id: args[:user_id],
      subgroup: args[:subgroup],
      requested_data: args[:requested_data]
    )

    authorize(data_request, :create?)

    data_request.public = data_request.exportable.public_data?(data_request.requested_data)
    data_request.status = DataRequest.statuses[:pending]
    data_request.save!

    DataRequestWorker.perform_async(data_request.id)
    data_request
  end

  def exportable
    @exportable ||= if args[:workflow_id]
                      Workflow.find(args[:workflow_id])
                    elsif args[:project_id]
                      Project.find(args[:project_id])
                    end
  end
end
