class AddColumnsToUserRoutineSession < ActiveRecord::Migration
  def self.up
    add_column :user_routine_sessions, :user_id, :integer
    add_column :user_routine_sessions, :routine_id, :integer
  end

  def self.down
    remove_column :user_routine_sessions, :user_id
    remove_column :user_routine_sessions, :routine_id
  end
end
