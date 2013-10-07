class AddColumnsToExercise < ActiveRecord::Migration
  def self.up
    add_column :exercises, :equipment_id, :integer
    add_column :exercises, :exercise_type, :string
    add_column :exercises, :force, :string
    add_column :exercises, :level, :string
    add_column :exercises, :mechanics_type, :string
  end

  def self.down
    remove_column :exercises, :equipment_id
    remove_column :exercises, :exercise_type
    remove_column :exercises, :force
    remove_column :exercises, :level
    remove_column :exercises, :mechanics_type
  end
end
