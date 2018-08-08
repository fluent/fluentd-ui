require "test_helper"

class Fluentd
  class AgentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @log = Object.new
      @agent = Object.new
      @fluentd = FactoryBot.build(:fluentd)
      stub(@agent).log { @log }
      stub(@fluentd).agent { @agent }
      stub(Fluentd).instance { @fluentd }


      user = FactoryBot.build(:user)
      post(sessions_path(session: { name: user.name, password: user.password }))


    end

    data("stop" => "stop",
         "start" => "start",
         "restart" => "restart",
         "reload" => "reload")
    test "the action succeed" do |action|
      mock(@agent).__send__(action) { true }
      put(__send__("#{action}_daemon_agent_path"))
    end

    data("stop" => "stop",
         "start" => "start",
         "restart" => "restart",
         "reload" => "reload")
    test "the action failure" do |action|
      mock(@agent).__send__(action) { false }
      mock(@log).tail(1) { ["dummylog"] } unless action == "stop"
      put(__send__("#{action}_daemon_agent_path"))
    end
  end
end
