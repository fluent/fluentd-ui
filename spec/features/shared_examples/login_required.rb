shared_examples_for "login required" do
  before { visit url }
  it { current_path.should == new_sessions_path }
end
