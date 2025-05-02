class Category < ApplicationRecord
    has_many :spaces
    
    validates :name, presence: true, uniqueness: true
  end