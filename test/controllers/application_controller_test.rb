require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    user = FactoryBot.build(:user)
    post(sessions_path(session: { name: user.name, password: user.password }))

    I18n.locale = I18n.default_locale # initialize
  end

  sub_test_case "with params[:lang]" do
    data("available locale" => [:ja, :ja],
        "unavailable locale" => [:ka, :en])
    test "locales" do |(locale, expected_locale)|
      get(daemon_path, params: { lang: locale })
      assert_equal(expected_locale, I18n.locale)
    end
  end

  sub_test_case "with session[:prefer_lang]" do
    setup do
      any_instance_of(ApplicationController) do |object|
        stub(object).locale_from_session { :ja }
      end
    end

    test "session[:prefer_lang] will be set as locale" do
      get(daemon_path)
      assert_equal(:ja, I18n.locale)
    end
  end

  sub_test_case "with request.env['HTTP_ACCEPT_LANGUAGE']" do
    data("available" =>["ja", :ja],
         "not available but start with en" => ["en-us", :en],
         "accept_language is invalid" => ["ka", :en])
    test "accept_language" do |(accept_language, expected_locale)|
      get(daemon_path, env: { "HTTP_ACCEPT_LANGUAGE" => accept_language })
      assert_equal(expected_locale, I18n.locale)
    end
  end
end
