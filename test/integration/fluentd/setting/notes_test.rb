require "test_helper"

class NotesTest < ActionDispatch::IntegrationTest
  include ConfigHistories::DaemonHaveSomeConfigHistories

  setup do
    login_with(FactoryBot.build(:user))
  end

  sub_test_case "update" do
    setup do
      visit("/daemon/setting/histories")
    end

    test "update a content of the first note" do
      content = "This config file is for ..."
      within(first("form")) do
        first(".note-content").set(content)
        click_button(I18n.t('terms.save'))
      end

      within(first("form")) do
        assert_equal(content, first(".note-content").value)
      end
    end
  end
end
