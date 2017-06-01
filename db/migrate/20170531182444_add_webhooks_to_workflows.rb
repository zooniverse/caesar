class AddWebhooksToWorkflows < ActiveRecord::Migration[5.0]
  def change
    add_column :workflows, :webhooks, :jsonb, null: true
  end
end
