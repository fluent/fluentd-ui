require 'spec_helper'
require 'active_ldap'

describe LdapAuthenticator do
  let(:user_name) { "admin" }
  let(:user_password) { "secret" }

  before do
    unless File.exist?(LdapSettings.source)
      skip "LDAP server configuration is required: #{LdapSettings.source}"
    end
  end

  def setup_configuration
    ActiveLdap::Base.configurations = {
      Rails.env => {
        "uri" => LdapSettings.uri,
        "password" => LdapSettings.authentication.password,
      },
    }
  end

  def setup_connection
    ActiveLdap::Base.setup_connection
  end

  def keep_original_data
    @dumped_data = nil
    begin
      @dumped_data = ActiveLdap::Base.dump(:scope => :sub)
    rescue ActiveLdap::ConnectionError
    end
  end

  def create_user(name, password)
    user_class = Class.new(ActiveLdap::Base) do
      ldap_mapping dn_attribute: "cn",
                   prefix: "",
                   classes: ["person"]
    end
    user = user_class.new(name)
    user.sn = name
    user.user_password = ActiveLdap::UserPassword.ssha(password)
    user.save!
  end

  def create_test_data
    ActiveLdap::Base.delete_all(nil, :scope => :sub)
    ActiveLdap::Populate.ensure_base
    create_user(user_name, user_password)
  end

  before do
    setup_configuration
    setup_connection
    keep_original_data
    create_test_data
  end

  def restore_original_data
    if @dumped_data
      ActiveLdap::Base.delete_all(nil, :scope => :sub)
      ActiveLdap::Base.load(@dumped_data)
    end
  end

  def close_connections
    ActiveLdap::Base.remove_active_connections!
  end

  after do
    restore_original_data
    close_connections
  end

  describe "#authenticate" do
    subject { LdapAuthenticator.new(LdapSettings) }

    context "success" do
      context "name only" do
        let(:user) { User.new(name: user_name) }
        it do
          subject.authenticate(user, user_password).should == true
        end
      end

      context "with attribute name" do
        let(:user) { User.new(name: "cn=#{user_name}") }
        it do
          subject.authenticate(user, user_password).should == true
        end
      end
    end

    context "failure" do
      context "nonexistent" do
        let(:user) { User.new(name: "nonexistent") }
        it do
          subject.authenticate(user, user_password).should == false
        end
      end
    end
  end
end
