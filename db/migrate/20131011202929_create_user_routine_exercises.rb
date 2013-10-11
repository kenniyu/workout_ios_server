class CreateUserRoutineExercises < ActiveRecord::Migration
  def change
    create_table :user_routine_exercises do |t|
      t.integer :user_id
      t.integer :exercise_id
      t.integer :routine_id
      t.string :status

      t.timestamps
    end
  end
end
