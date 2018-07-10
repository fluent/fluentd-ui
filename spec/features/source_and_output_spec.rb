require "spec_helper"

describe "source_and_output", js: true, stub: :daemon do
  let(:exists_user) { build(:user) }

  before do
    login_with exists_user
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

      page.should have_css('.input .card .card-header')
      page.should have_css('.output .card .card-header')
    end

    it ".card-body is hidden by default and click .card-header for display"  do
      page.should_not have_css('.input .card .card-body')
      page.should_not have_css('.output .card .card-body')
      all(".input .card .card-header").first.click
      page.should have_css('.input .card .card-body')
      all(".output .card .card-header").first.click
      page.should have_css('.output .card .card-body')
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
      all(".input .card .card-header").first.click
    end

    it "click edit button transform textarea, then click cancel button to be reset" do
      skip "Doesn't work on Poltergeist"
      page.should_not have_css('.input textarea')
      find(".btn", text: I18n.t('terms.edit')).click
      page.evaluate_script(<<-JS).should == config_contents
        document.querySelector("textarea").codemirror.getValue()
      JS
      page.evaluate_script <<-JS
        var cm = document.querySelector('textarea').codemirror;
        cm.setValue(JSON.parse(#{new_config.to_json}));
      JS
      find(".btn", text: I18n.t('terms.cancel')).click
      content = wait_until do
        page.evaluate_script("document.querySelector('.input pre').textContent")
      end
      content.should == config_contents
      daemon.agent.config.strip.should == config_contents.strip
    end

    it "click edit button transform textarea, then click update button to be stored" do
      skip "Doesn't work on Poltergeist"
      page.should_not have_css('.input textarea')
      find(".btn", text: I18n.t('terms.edit')).click
      page.evaluate_script(<<-JS).should == config_contents
        document.querySelector("textarea").codemirror.getValue()
      JS
      page.evaluate_script <<-JS
        var cm = document.querySelector('textarea').codemirror;
        cm.setValue(JSON.parse(#{new_config.to_json}));
      JS
      find(".btn", text: I18n.t('terms.save')).click
      content = wait_until do
        page.evaluate_script("document.querySelector('.input pre').textContent")
      end
      content.should == new_config
      daemon.agent.config.strip.should == new_config.strip
    end

    it "click delete button transform textarea" do
      skip "accept_confirm does not work properly"
      page.should have_css('.input .card-body')
      accept_confirm do
        find(".btn", text: I18n.t('terms.destroy')).click
      end
      page.should_not have_css('.input .card-body')
      daemon.agent.config.strip.should == ""
    end

    it "click delete button then cancel it" do
      skip "accept_confirm does not work properly"
      page.should have_css('.input .card-body')
      dismiss_confirm do
        find(".btn", text: I18n.t('terms.destroy')).click
      end
      page.should have_css('.input .card-body')
      daemon.agent.config.strip.should == config_contents.strip
    end
  end
end
