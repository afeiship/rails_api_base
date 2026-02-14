class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content
      t.string :status, default: 'draft'
      t.integer :views, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :posts, :status
    add_index :posts, :views
  end
end
