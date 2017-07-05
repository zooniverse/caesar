class RenameWebhooksWebhooksConfig < ActiveRecord::Migration[5.0]
  def change
    rename_column :workflows, :webhooks, :webhooks_config
  end
end
