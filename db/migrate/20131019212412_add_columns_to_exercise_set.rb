class AddColumnsToExerciseSet < ActiveRecord::Migration
  def self.up
    add_column :exercise_sets, :session_id, :integer
    add_column :exercise_sets, :working_time, :decimal
    add_column :exercise_sets, :resting_time, :decimal
  end

  def self.down
    remove_column :exercise_sets, :session_id
    remove_column :exercise_sets, :working_time
    remove_column :exercise_sets, :resting_time
  end
end
