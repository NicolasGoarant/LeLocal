class ChangeEquipmentNeedsToArrayInNeeds < ActiveRecord::Migration[6.1]
  def change
    # On ajoute la colonne en tant que tableau, peu importe si elle existait ou non avant
    add_column :needs, :equipment_needs, :string, array: true, default: [], null: false
  end
end
