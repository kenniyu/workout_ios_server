class CreateRoutines < ActiveRecord::Migration
  def change
    create_table :routines do |t|
      t.integer :creator_id
      t.text :description
      t.string :name

      t.timestamps
    end
  end
end
