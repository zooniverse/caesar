class RemoveWebhooks < ActiveRecord::Migration[5.1]
  def change
    remove_column :workflows, :webhooks_config
    remove_column :projects, :webhooks
  end
end
