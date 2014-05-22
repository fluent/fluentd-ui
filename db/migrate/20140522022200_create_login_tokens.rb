class CreateLoginTokens < ActiveRecord::Migration
  def change
    create_table :login_tokens do |t|
      t.string :token_id, null: false, unique: true
      t.integer :user_id, null: false
      t.datetime :expired_at

      t.index :token_id

      t.timestamps
    end
  end
end
