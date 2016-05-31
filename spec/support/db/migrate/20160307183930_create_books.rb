class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.integer  'author_id', limit: 4
      t.string   'title',     limit: 255
      t.integer  'year',      limit: 4
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end

    add_foreign_key 'books', 'authors', on_delete: :nullify
  end
end
