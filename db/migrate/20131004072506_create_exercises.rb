class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :name
      t.integer :user_id
      t.integer :exercise_category_id

      t.timestamps
    end
  end
end
