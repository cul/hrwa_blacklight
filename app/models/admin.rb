class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise    :database_authenticatable,
            :registerable,
            :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  # Add custom validation for username - This is necessary
  # because while email is validated by default, username
  # is not (even though it's unique in the database).
  validates_presence_of :username
  validates_uniqueness_of :username

end
