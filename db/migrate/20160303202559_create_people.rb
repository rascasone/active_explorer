class CreatePeople < ActiveRecord::Migration
  def change
    create_table "people", force: :cascade do |t|
      t.string   "first_name",     limit: 255
      t.string   "last_name",      limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
