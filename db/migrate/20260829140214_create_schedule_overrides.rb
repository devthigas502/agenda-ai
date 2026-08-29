class CreateScheduleOverrides < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_overrides, id: :uuid do |t|
      t.references :professional, null: false, foreign_key: true, type: :uuid

      t.date :date, null: false
      t.time :starts_at
      t.time :ends_at
      t.string :reason
      t.boolean :blocked, null: false, default: false

      t.timestamps
    end

    add_index :schedule_overrides, [:professional_id, :date]
  end
end
