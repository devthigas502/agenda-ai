class CreateBookingStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_status_changes, id: :uuid do |t|
      t.references :booking, null: false, foreign_key: true, type: :uuid

      t.string :from_status
      t.string :to_status, null: false
      t.string :changed_by
      t.text :reason

      t.timestamps
    end
  end
end
