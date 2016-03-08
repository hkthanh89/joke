class CreateJokes < ActiveRecord::Migration
  def change
    create_table :jokes do |t|
      t.text :content
      t.integer :like
      t.integer :dislike

      t.timestamps
    end
  end
end
