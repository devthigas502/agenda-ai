class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :phone
      t.string :email
      t.string :timezone, null: false, default: "America/Sao_Paulo"
      t.json :settings, null: false, default: {}
      t.string :plan, null: false, default: "trial"
      t.datetime :trial_ends_at

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
  end
end
