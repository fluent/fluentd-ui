class User
  include ActiveModel::Model
  include ActiveModel::SecurePassword

  has_secure_password

  ENCRYPTED_PASSWORD_FILE = Rails.env.test? ? "tmp/test.txt" : Rails.root + "db/user.txt"

  attr_accessor :name, :password, :password_confirmation, :current_password

  validates :name, presence: true
  validates :password, length: { minimum: 8 }
  validate :valid_current_password

  def password_digest
    @password_digest ||
      begin
        File.read(ENCRYPTED_PASSWORD_FILE).rstrip
      rescue Errno::ENOENT
        BCrypt::Password.create(Settings.default_password, cost: cost)
      end
  end

  def password_digest=(digest)
    @password_digest = digest
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

  def valid_current_password
    unless authenticate(current_password)
      errors.add(:current_password, :wrong_password)
    end
  end
end
