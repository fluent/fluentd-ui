module StubDaemon
  shared_context 'stub daemon', stub: :daemon do
    let!(:exists_user) { build(:user) }
    let!(:daemon) { build(:fluentd, variant: "td-agent") }

    before do
      Fluentd.stub(:instance).and_return(daemon)
      Fluentd::Agent::TdAgent.any_instance.stub(:detached_command).and_return(true)
      daemon.agent.config_write ""
    end
  end
end
