Rails.application.config.middleware.use OmniAuth::Builder do
  provider(:zooniverse,
           ENV['PANOPTES_CLIENT_ID'],
           ENV['PANOPTES_CLIENT_SECRET'],
           client_options: {
             site: (Rails.env.production? ? "https://panoptes.zooniverse.org" : "https://panoptes-staging.zooniverse.org"),
             authorize_url: "/oauth/authorize",
             scope: ['user', 'public']
           })
end
