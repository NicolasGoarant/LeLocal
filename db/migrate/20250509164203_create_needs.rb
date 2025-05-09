class CreateNeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :needs do |t|
      t.string :title
      t.text :description
      t.string :city
      t.integer :surface_min
      t.string :duration
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
