require "test_helper"

class PollingControllerTest < ActionDispatch::IntegrationTest
  setup do
    user = FactoryBot.build(:user)
    post(sessions_path(session: { name: user.name, password: user.password }))
  end

  test "may find nothing" do
    stub(Plugin).installing { [] }
    stub(Plugin).uninstalling { [] }
    get(polling_alerts_path)
    assert_response(:success)
  end

  test "may find gems being uninstalled" do
    stub(Plugin).installing { [] }
    stub(Plugin).uninstalling { [FactoryBot.build(:plugin)] }
    get(polling_alerts_path)
    assert_response(:success)
  end

  test "may find gems being installed" do
    stub(Plugin).installing { [FactoryBot.build(:plugin)] }
    stub(Plugin).uninstalling { [] }
    get(polling_alerts_path)
    assert_response(:success)
  end
end
