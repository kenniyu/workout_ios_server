class CreateMuscles < ActiveRecord::Migration
  def change
    create_table :muscles do |t|
      t.string :alias
      t.string :name

      t.timestamps
    end
  end
end
