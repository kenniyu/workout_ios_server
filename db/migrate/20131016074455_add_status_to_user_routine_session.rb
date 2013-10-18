class AddStatusToUserRoutineSession < ActiveRecord::Migration
  def self.up
    add_column :user_routine_sessions, :status, :string
  end

  def self.down
    remove_column :user_routine_sessions, :status
  end
end
