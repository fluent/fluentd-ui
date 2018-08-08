require "test_helper"

class PluginDecoratorTest < ActiveSupport::TestCase
  setup do
    @plugin = FactoryBot.build(:plugin).decorate
  end

  sub_test_case "#status" do
    test "returns the term for processing while processing" do
      mock(@plugin.object).processing? { true }
      assert_equal(I18n.t("terms.processing"), @plugin.status)
    end

    test "already installed" do
      stub(@plugin.object).processing? { false }
      stub(@plugin.object).installed? { true }
      assert_equal(I18n.t("terms.installed"), @plugin.status)
    end

    test "not installed yet" do
      stub(@plugin.object).processing? { false }
      stub(@plugin.object).installed? { false }
      assert_equal(I18n.t("terms.not_installed"), @plugin.status)
    end
  end
end
