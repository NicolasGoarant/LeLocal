class AddAssociationNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :association_name, :string
  end
end
