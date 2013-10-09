class CreateRoutineExercises < ActiveRecord::Migration
  def change
    create_table :routine_exercises do |t|
      t.integer :routine_id
      t.integer :exercise_id

      t.timestamps
    end
  end
end
