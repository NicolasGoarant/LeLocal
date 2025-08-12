class AddContactsToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :contact_email, :string
    add_column :needs, :contact_phone, :string
  end
end
