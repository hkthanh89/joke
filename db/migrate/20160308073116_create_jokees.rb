class CreateJokees < ActiveRecord::Migration
  def change
    create_table :jokees do |t|
      t.text :content
      t.integer :like
      t.integer :dislike

      t.timestamps
    end
  end
end
