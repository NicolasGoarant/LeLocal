class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Types de compte
  ACCOUNT_TYPES = ['association', 'owner'].freeze
  
  # Validations
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }, allow_nil: true
  validates :terms_accepted, acceptance: { accept: true }, on: :create

  def display_name
    if account_type == 'association'
      association_name.presence || "#{first_name} #{last_name}"
    else
      "#{first_name} #{last_name}"
    end
  end
end
