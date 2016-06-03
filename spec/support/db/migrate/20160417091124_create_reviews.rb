class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer 'stars', limit: 4
      t.text    'text'

      t.timestamps null: false

      t.belongs_to :book, foreign_key: true, index: true, on_delete: :cascade
      t.belongs_to :author, foreign_key: true, index: true, on_delete: :nullify
    end
  end
end
