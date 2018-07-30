module LoginRequired
  def login_required(url)
    visit(url)
    assert_equal(new_sessions_path, current_path)
  end
end

ActionDispatch::IntegrationTest.include(LoginRequired)
