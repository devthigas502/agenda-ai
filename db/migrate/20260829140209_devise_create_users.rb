class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid

      t.string :name, null: false

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Role
      t.string :role, null: false, default: "owner"

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
