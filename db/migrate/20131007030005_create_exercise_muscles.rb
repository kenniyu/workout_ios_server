class CreateExerciseMuscles < ActiveRecord::Migration
  def change
    create_table :exercise_muscles do |t|
      t.integer :exercise_id
      t.string :focus
      t.integer :muscle_id

      t.timestamps
    end
  end
end
