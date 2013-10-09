class CreateRoutineTags < ActiveRecord::Migration
  def change
    create_table :routine_tags do |t|
      t.integer :routine_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
