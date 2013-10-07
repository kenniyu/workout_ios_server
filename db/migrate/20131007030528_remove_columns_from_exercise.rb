class RemoveColumnsFromExercise < ActiveRecord::Migration
  def self.up
    remove_column :exercises, :user_id
    remove_column :exercises, :exercise_category_id
  end

  def self.down
    add_column :exercises, :user_id, :integer
    add_column :exercises, :exercise_category_id, :integer
  end
end
