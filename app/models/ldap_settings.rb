class LdapSettings < Settingslogic
  source "#{Rails.root}/config/ldap.yml"
  namespace Rails.env
end
