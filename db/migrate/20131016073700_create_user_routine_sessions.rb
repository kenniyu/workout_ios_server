class CreateUserRoutineSessions < ActiveRecord::Migration
  def change
    create_table :user_routine_sessions do |t|

      t.timestamps
    end
  end
end
