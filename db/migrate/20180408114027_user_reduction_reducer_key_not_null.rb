class UserReductionReducerKeyNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:user_reductions, :reducer_key, false )
  end
end
