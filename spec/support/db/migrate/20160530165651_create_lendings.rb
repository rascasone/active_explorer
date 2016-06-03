class CreateLendings < ActiveRecord::Migration
  def change
    create_table 'lendings', force: :cascade do |t|
      t.references :person, foreign_key: true, on_delete: :cascade
      t.references :book, foreign_key: true, on_delete: :cascade

      t.string 'state'

      t.timestamps null: false
    end
  end
end
