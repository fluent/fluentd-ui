shared_examples_for "configurable daemon settings" do |type, form_name, form_value|
  it "Shown form with filled in td.*.* on match" do
    visit send("daemon_setting_#{type}_path")
    page.should have_css("input[name=\"fluentd_setting_#{type}[#{form_name}]\"]")
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(form_value)
    visit send("daemon_setting_#{type}_path")
    within("#new_fluentd_setting_#{type}") do
      fill_in form_name.capitalize, with: form_value
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(form_value)
  end

end
