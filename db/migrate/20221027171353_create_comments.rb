class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :message_id
      t.string :content
      t.integer :is_archived

      t.timestamps
    end
  end
end
