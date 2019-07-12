if Rails.env.development? || Rails.env.test?
  StrongMigrations.start_after = 20190710204342
end
