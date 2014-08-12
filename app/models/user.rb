# NOTE: Application has "admin" user only
#       admin's password can be changed from browser, but user name "admin" can't be changed.
#       many clients can login at the same time (App has multiple active sessions)
#       raw password shouldn't be compromised (except default password)
#       you may find detail at https://github.com/treasure-data/fluentd-ui/pull/34

class User
  include ActiveModel::Model
  include ActiveModel::SecurePassword

  has_secure_password

  ENCRYPTED_PASSWORD_FILE = Rails.root + "db/#{Rails.env}-user.txt"

  attr_accessor :name, :password, :password_confirmation, :current_password
  attr_writer :password_digest

  validates :name, presence: true
  validates :password, length: { minimum: 8 }

  def password_digest
    @password_digest ||
      begin
        hash = File.read(ENCRYPTED_PASSWORD_FILE).rstrip
        BCrypt::Password.new(hash) # raise BCrypt::Errors::InvalidHash if hash is invalid
      rescue Errno::ENOENT, BCrypt::Errors::InvalidHash
        BCrypt::Password.create(Settings.default_password, cost: cost)
      end
  end

  def update_attributes(params)
    params.each_pair do |key, value|
      send("#{key}=", value)
    end
    return false unless valid?

    File.open(ENCRYPTED_PASSWORD_FILE, "w") do |f|
      f.write BCrypt::Password.create(password, cost: cost)
    end
  end

  def cost
    Rails.env.test? ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
  end
end
