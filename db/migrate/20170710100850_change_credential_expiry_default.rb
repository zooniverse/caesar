class ChangeCredentialExpiryDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :credentials, :expires_at, nil
  end
end
