class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :account_type, :string
    add_column :users, :phone, :string
    add_column :users, :terms_accepted, :boolean
    add_column :users, :newsletter, :boolean
  end
end
