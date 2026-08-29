class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules, id: :uuid do |t|
      t.references :professional, null: false, foreign_key: true, type: :uuid

      t.integer :weekday, null: false  # 0=Sunday, 6=Saturday
      t.time :starts_at, null: false
      t.time :ends_at, null: false

      t.timestamps
    end

    add_index :schedules, [:professional_id, :weekday]
  end
end
