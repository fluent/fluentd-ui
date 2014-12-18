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

      #remove backups on each to avoid depending on spec execution order
      FileUtils.rm_r daemon.agent.config_backup_dir, force: true

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

  shared_context 'daemon had been started once' do
    let!(:backup_content){ "Running backup file content" }

    before do
      File.open(daemon.agent.running_config_backup_file, "w") do |file|
        file.write(backup_content)
      end
    end

    after do
      FileUtils.rm_r daemon.agent.running_config_backup_dir, force: true
    end
  end
end
