class AddAddressToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :address, :string
  end
end
