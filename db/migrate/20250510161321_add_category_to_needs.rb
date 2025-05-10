class AddCategoryToNeeds < ActiveRecord::Migration[8.0]
  def change
    add_column :needs, :category, :string
  end
end
