class AddPostalCodeToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :postal_code, :string
  end
end
