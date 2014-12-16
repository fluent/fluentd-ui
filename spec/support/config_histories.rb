module ConfigHistories
  shared_context 'daemon has some config histories' do
    let!(:three_hours_ago) { Time.zone.now - 3.hours }
    let(:config_contents) { <<-CONF.strip_heredoc }
      <source>
        type forward
        port 24224
      </source>
    CONF

    let(:new_config) { <<-CONF.strip_heredoc }
      <source>
        type http
        port 8899
      </source>
    CONF

    before do
      Timecop.freeze(three_hours_ago)

      7.times do |i|
        backpued_time = three_hours_ago - (i + 1).hours
        FileUtils.touch daemon.agent.config_backup_dir + "/#{backpued_time.strftime('%Y%m%d_%H%M%S')}.conf"
      end

      Timecop.freeze(three_hours_ago + 1.hour)
      daemon.agent.config_write config_contents #add before conf

      Timecop.freeze(three_hours_ago + 2.hour)
      daemon.agent.config_write new_config #update conf

      Timecop.freeze(three_hours_ago + 3.hour)
    end

    after do
      FileUtils.rm_r daemon.agent.config_backup_dir, force: true
      Timecop.return
    end
  end
end
