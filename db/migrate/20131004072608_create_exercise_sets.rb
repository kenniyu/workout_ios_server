class CreateExerciseSets < ActiveRecord::Migration
  def change
    create_table :exercise_sets do |t|
      t.integer :user_id
      t.integer :exercise_id
      t.integer :reps

      t.timestamps
    end
  end
end
