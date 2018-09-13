require "application_system_test_case"

class FilterGrepTest < ApplicationSystemTestCase
  setup do
    login_with(FactoryBot.build(:user))
    @daemon = stub_daemon
  end

  test "show form" do
    visit(daemon_setting_filter_grep_path)
    assert do
      page.has_css?("input[name=\"setting[label]\"]")
    end
    assert do
      page.has_css?("input#setting_and_0_regexp_0__key")
    end
    assert do
      page.has_css?("input#setting_and_0_regexp_0__pattern")
    end
    assert do
      page.has_css?("input#setting_or_0_regexp_0__key")
    end
    assert do
      page.has_css?("input#setting_or_0_regexp_0__pattern")
    end
  end

  test "append and" do
    visit(daemon_setting_filter_grep_path)
    first(".card-header .btn .fa-plus").click
    assert do
      page.has_css?("input#setting_and_1_regexp_0__key")
    end
    assert do
      page.has_css?("input#setting_and_1_regexp_0__pattern")
    end
    first(".card-header .btn .fa-minus").click
    assert do
      !page.has_css?("input#setting_and_1_regexp_0__key")
    end
    assert do
      !page.has_css?("input#setting_and_1_regexp_0__pattern")
    end
  end

  test "append regexp" do
    visit(daemon_setting_filter_grep_path)
    first(".card-body .btn .fa-plus").click
    assert do
      page.has_css?("input#setting_and_0_regexp_1__key")
    end
    assert do
      page.has_css?("input#setting_and_0_regexp_1__pattern")
    end
    first(".card-body .btn .fa-minus").click
    assert do
      !page.has_css?("input#setting_and_0_regexp_1__key")
    end
    assert do
      !page.has_css?("input#setting_and_0_regexp_1__pattern")
    end
  end

  test "toggle regexp/exclude" do
    visit(daemon_setting_filter_grep_path)
    assert_equal(first(".card-body label").text, "Regexp")
    first('input[name="setting[and[0]][grep_type]"][value="exclude"]').click()
    assert_equal(first(".card-body label").text, "Exclude")
    assert do
      !page.has_css?("input#setting_and_0_regexp_0__key")
    end
    assert do
      !page.has_css?("input#setting_and_0_regexp_0__pattern")
    end
    assert do
      page.has_css?("input#setting_and_0_exclude_0__key")
    end
    assert do
      page.has_css?("input#setting_and_0_exclude_0__pattern")
    end
  end

  test "update config" do
    visit(daemon_setting_filter_grep_path)
    within("form") do
      fill_in("setting_label", with: "@INPUT")
      fill_in("setting_pattern", with: "pattern")
      fill_in("setting_and_0_regexp_0__key", with: "message")
      fill_in("setting_and_0_regexp_0__pattern", with: "pattern")
    end
    click_button(I18n.t("fluentd.common.finish"))
    assert do
      @daemon.agent.config.include?("@INPUT")
    end
  end
end
