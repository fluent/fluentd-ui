class User < ActiveRecord::Base
  has_secure_password

  attr_accessor :current_password

  has_many :login_tokens

  validates :name, uniqueness: true, presence: true
  validates :password, length: { minimum: 8 }
end
