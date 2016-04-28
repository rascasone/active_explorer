class CreateBadGuys < ActiveRecord::Migration
  def change
    create_table :bad_guys do |t|
      t.string  'nickname'

      t.timestamps null: false
    end
  end
end
