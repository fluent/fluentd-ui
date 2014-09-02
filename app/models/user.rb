# NOTE: Application has "admin" user only
#       admin's password can be changed from browser, but user name "admin" can't be changed.
#       many clients can login at the same time (App has multiple active sessions)
#       raw password shouldn't be compromised (except default password)
#       you may find detail at https://github.com/treasure-data/fluentd-ui/pull/34

class User
  include ActiveModel::Model

  SALT = "XG16gfdC5IFRaQ3c".freeze
  ENCRYPTED_PASSWORD_FILE = FluentdUI.data_dir + "/#{Rails.env}-user-pwhash.txt"

  attr_accessor :name, :password, :password_confirmation, :current_password

  validates :name, presence: true
  validates :password, length: { minimum: 8 }
  validate :valid_current_password
  validate :valid_password_confirmation

  def authenticate(unencrypted_password)
    digest(unencrypted_password) == stored_digest
  end

  def digest(unencrypted_password)
    unencrypted_password ||= ""
    hash = Digest::SHA1.hexdigest(SALT + unencrypted_password)
    stretching_cost.times do
      hash = Digest::SHA1.hexdigest(hash + SALT + unencrypted_password)
    end
    hash
  end

  def stored_digest
    if File.exist?(ENCRYPTED_PASSWORD_FILE)
      File.read(ENCRYPTED_PASSWORD_FILE).rstrip
    else
      digest(Settings.default_password)
    end
  end

  def update_attributes(params)
    params.each_pair do |key, value|
      send("#{key}=", value)
    end
    return false unless valid?

    File.open(ENCRYPTED_PASSWORD_FILE, "w") do |f|
      f.write digest(password)
    end
  end

  def valid_current_password
    unless authenticate(current_password)
      errors.add(:current_password, :wrong_password)
    end
  end

  def valid_password_confirmation
    password == password_confirmation
  end

  def stretching_cost
    Rails.env.test? ? 1 : 20000
  end
end
