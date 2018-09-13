module ConfigurableDaemonSettings
  extend ActiveSupport::Concern

  included do
    test "show form" do
      visit(__send__("daemon_setting_#{@type}_path"))
      assert do
        page.has_css?("input[name=\"setting[#{@form_name}]\"]")
      end
    end

    test "Update config" do
      assert do
        !@daemon.agent.config.include?(@form_value)
      end
      visit(__send__("daemon_setting_#{@type}_path"))
      within("form") do
        fill_in(@form_name.humanize, with: @form_value)
      end
      click_button(I18n.t("fluentd.common.finish"))
      assert do
        @daemon.agent.config.include?(@form_value)
      end
    end
  end
end
