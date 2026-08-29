class CreateProfessionals < ActiveRecord::Migration[8.1]
  def change
    create_table :professionals, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid

      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :bio
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :professionals, [:account_id, :position]
  end
end
