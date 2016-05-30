class CreateLendings < ActiveRecord::Migration
  def change
    create_table 'lendings', force: :cascade do |t|
      t.references(:person, foreign_key: true)
      t.references(:book, foreign_key: true)

      t.string 'state'

      t.timestamps null: false
    end
  end
end
