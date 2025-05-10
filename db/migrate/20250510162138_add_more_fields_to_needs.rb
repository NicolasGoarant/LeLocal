class AddMoreFieldsToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :country, :string
    add_column :needs, :latitude, :float
    add_column :needs, :longitude, :float
    add_column :needs, :start_time, :string
    add_column :needs, :end_time, :string
    add_column :needs, :budget, :integer
    add_column :needs, :recurrence, :string
  end
end
