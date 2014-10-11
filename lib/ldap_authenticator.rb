require "net/ldap"

class LdapAuthenticator
  def initialize(settings)
    @settings = settings
  end

  def authenticate(user, unencrypted_password)
    uri = URI.parse(@settings.uri)
    ldap = Net::LDAP.new(host: uri.host,
                         port: uri.port,
                         encryption: encryption(uri))
    expanded_user_name = expand_user_name(user, ldap, uri)
    return false if expanded_user_name.nil?
    user.name = expanded_user_name

    authentication = @settings["authentication"] || {}
    auth = {
      method:   (authentication["method"] || "simple").to_sym,
      username: user.name,
      password: unencrypted_password,
    }
    ldap.bind(auth)
  end

  private
  def encryption(uri)
    if uri.is_a?(URI::LDAPS)
      encryption = :simple_tls
    elsif @settings["start_tls"]
      encryption = :start_tls
    else
      encryption = nil
    end
  end

  def expand_user_name(user, ldap, uri)
    ldap.bind
    if user.name.include?("=")
      rdn_attribute, rdn_value = user.name.split("=", 2)
      filter = Net::LDAP::Filter.eq(rdn_attribute, rdn_value)
    else
      filter =
        Net::LDAP::Filter.eq("cn", user.name) |
        Net::LDAP::Filter.eq("uid", user.name)
    end
    if uri.filter
      filter = Net::Ldap::Filter.construct(uri.filter) & filter
    end
    case uri.scope
    when "one"
      scope = Net::LDAP::SearchScope_SingleLevel
    when "base"
      scope = Net::LDAP::SearchScope_BaseObject
    else
      scope = Net::LDAP::SearchScope_WholeSubtree
    end
    entries = ldap.search(filter: filter,
                          base: uri.dn,
                          attributes: ["dn"],
                          scope: scope,
                          size: 1)
    return nil if entries.nil?
    return nil if entries.empty?

    entries.first[:dn].first
  end
end
