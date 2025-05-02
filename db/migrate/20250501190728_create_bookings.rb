class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.integer :space_id
      t.integer :user_id
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :status
      t.decimal :total_price

      t.timestamps
    end
  end
end
