Effects.panoptes = Panoptes::Client.new(env: Rails.env.to_s,
                                        auth: {client_id: ENV.fetch("PANOPTES_CLIENT_ID"),
                                               client_secret: ENV.fetch("PANOPTES_CLIENT_SECRET")})
