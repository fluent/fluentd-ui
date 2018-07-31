module StubDaemon
  def stub_daemon(running: false, variant: "td-agent")
    daemon = FactoryBot.build(:fluentd, variant: variant)
    stub(Fluentd).instance { daemon }
    any_instance_of(Fluentd::Agent::TdAgent) do |object|
      stub(object).detached_command { true }
      stub(object).running? { running }
    end
    daemon.agent.config_write("")
    daemon
  end
end

ActionDispatch::IntegrationTest.include(StubDaemon)
