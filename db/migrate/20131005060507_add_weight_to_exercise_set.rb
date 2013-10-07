class AddWeightToExerciseSet < ActiveRecord::Migration
  def self.up
    add_column :exercise_sets, :weight, :decimal
  end

  def self.down
    remove_column :exercise_sets, :weight
  end
end
