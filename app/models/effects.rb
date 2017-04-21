module Effects
  class FakePanoptes
    def method_missing(method_name, *args)
      Rails.logger.info(">>> Panoptes API call [#{method_name}], args: #{args.inspect}")
      nil
    end
  end

  def self.panoptes
    return @panoptes if @panoptes

    if ENV.key?("PANOPTES_CLIENT_ID") || Rails.env.staging? || Rails.env.production?
      @panoptes = Panoptes::Client.new(env: Rails.env.to_s,
                                       auth: {client_id: ENV.fetch("PANOPTES_CLIENT_ID"),
                                              client_secret: ENV.fetch("PANOPTES_CLIENT_SECRET")},
                                              params: {:admin => true})
    else
      @panoptes = FakePanoptes.new
    end
  end

  def self.panoptes=(adapter)
    @panoptes = adapter
  end
end
