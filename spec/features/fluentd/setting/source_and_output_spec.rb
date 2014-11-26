require "spec_helper"

describe "source_and_output", js: true do
  let(:exists_user) { build(:user) }
  let(:daemon) { build(:fluentd, variant: "td-agent") }

  before do
    Fluentd.stub(:instance).and_return(daemon)
    Fluentd::Agent::TdAgent.any_instance.stub(:detached_command).and_return(true)
  end

  before do
    visit '/sessions/new'
    within("form") do
      fill_in 'session_name', :with => exists_user.name
      fill_in 'session_password', :with => exists_user.password
    end
    click_button I18n.t("terms.sign_in")
  end

  before do
    daemon.agent.config_write config_contents
    visit source_and_output_daemon_setting_path
  end

  context "config is blank" do
    let(:config_contents) { "" }
    it do
      page.should have_content(I18n.t("fluentd.settings.source_and_output.setting_empty"))
      page.should have_css(".input .empty")
      page.should have_css(".output .empty")
    end
  end

  context "config is given" do
    let(:config_contents) { <<-CONF.strip_heredoc }
      <source>
        # http://docs.fluentd.org/articles/in_forward
        type forward
        port 24224
      </source>

      <match debug.*>
        # http://docs.fluentd.org/articles/out_stdout
        type stdout
      </match>

      <match s3.*>
        type s3
        aws_key_id fofoaiofa
        aws_sec_key aaaaaaaaaaaaaae
        s3_bucket test
        s3_endpoint s3-us-west-1.amazonaws.com
        format out_file
        include_time_key false
        add_newline false
        output_tag true
        output_time true
        store_as gzip
        use_ssl true
        buffer_type memory
      </match>
    CONF

    it do
      page.should_not have_content(I18n.t("fluentd.settings.source_and_output.setting_empty"))

      page.should have_css('.input .panel .panel-heading')
      page.should have_css('.output .panel .panel-heading')
    end

    it ".panel-body is hidden by default and click .panel-heading for display"  do
      page.should_not have_css('.input .panel .panel-body')
      page.should_not have_css('.output .panel .panel-body')
      all(".input .panel .panel-heading").first.click
      page.should have_css('.input .panel .panel-body')
      all(".output .panel .panel-heading").first.click
      page.should have_css('.output .panel .panel-body')
    end

    it "display plugin name" do
      within ".input" do
        page.should have_content("forward")
      end

      within ".output" do
        page.should have_content("stdout")
        page.should have_content("s3")
      end
    end
  end

  describe "edit, update, delete" do
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
      all(".input .panel .panel-heading").first.click
    end

    it "click edit button transform textarea, then click cancel button to be reset" do
      page.should_not have_css('.input textarea')
      find(".btn", text: I18n.t('terms.edit')).click
      page.should have_css('.input textarea')
      find('.input textarea').value.should == config_contents
      find('.input textarea').set "foo"
      find(".btn", text: I18n.t('terms.cancel')).click
      content = wait_until do
        page.evaluate_script("document.querySelector('.input pre').textContent")
      end
      content.should == config_contents
      daemon.agent.config.strip.should == config_contents.strip
    end

    it "click edit button transform textarea, then click update button to be stored" do
      page.should_not have_css('.input textarea')
      find(".btn", text: I18n.t('terms.edit')).click
      page.should have_css('.input textarea')
      find('.input textarea').value.should == config_contents
      find('.input textarea').set new_config
      find(".btn", text: I18n.t('terms.update')).click
      content = wait_until do
        page.evaluate_script("document.querySelector('.input pre').textContent")
      end
      content.should == new_config
      daemon.agent.config.strip.should == new_config.strip
    end

    it "click delete button transform textarea" do
      page.should have_css('.input .panel-body')
      confirm_dialog(true) do
        find(".btn", text: I18n.t('terms.destroy')).click
      end
      page.should_not have_css('.input .panel-body')
      daemon.agent.config.strip.should == ""
    end

    it "click delete button then cancel it" do
      page.should have_css('.input .panel-body')
      confirm_dialog(false) do
        find(".btn", text: I18n.t('terms.destroy')).click
      end
      page.should have_css('.input .panel-body')
      daemon.agent.config.strip.should == config_contents.strip
    end
  end
end
