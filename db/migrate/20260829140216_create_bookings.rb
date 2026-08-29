class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :professional, null: false, foreign_key: true, type: :uuid
      t.references :service, null: false, foreign_key: true, type: :uuid
      t.references :client, null: false, foreign_key: true, type: :uuid

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, null: false, default: "pending"
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "BRL"
      t.text :notes
      t.string :source, null: false, default: "public_page"

      t.timestamps
    end

    add_index :bookings, [:professional_id, :starts_at, :ends_at]
    add_index :bookings, [:account_id, :status]
    add_index :bookings, :starts_at
  end
end
