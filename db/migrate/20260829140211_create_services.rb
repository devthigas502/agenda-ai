class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid

      t.string :name, null: false
      t.text :description
      t.integer :duration_minutes, null: false
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "BRL"
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :services, [:account_id, :position]
  end
end
