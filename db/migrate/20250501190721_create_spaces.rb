class CreateSpaces < ActiveRecord::Migration[8.0]
  def change
    create_table :spaces do |t|
      t.string :name
      t.text :description
      t.string :address
      t.integer :capacity
      t.decimal :price_per_hour
      t.decimal :rating
      t.string :images
      t.float :latitude
      t.float :longitude
      t.string :category

      t.timestamps
    end
  end
end
