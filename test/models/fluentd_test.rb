require "test_helper"

class FluentdTest < ActiveSupport::TestCase
  module PathPermission
    def self.included(base)
      base.class_eval do
        setup do
          setup_target
        end

        sub_test_case "file exists" do
          setup do
            FileUtils.touch(@path)
          end

          teardown do
            FileUtils.rm_f(@path)
          end

          test "writable" do
            FileUtils.chmod(0600, @path)
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.blank?
            end
          end

          test "not writable" do
            FileUtils.chmod(0400, @path)
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.present?
            end
            assert_equal(I18n.t('activerecord.errors.messages.lack_write_permission'), @fluentd.errors[@column].first)
          end

          test "not readable" do
            FileUtils.chmod(0200, @path)
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.present?
            end
            assert_equal(I18n.t('activerecord.errors.messages.lack_read_permission'), @fluentd.errors[@column].first)
          end

          test "is directory" do
            @fluentd.__send__("#{@column}=", Rails.root + "tmp")
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.present?
            end
            assert_equal(I18n.t('activerecord.errors.messages.is_a_directory'), @fluentd.errors[@column].first)
          end
        end

        sub_test_case "file not exists" do
          setup do
            @dir = File.dirname(@path)
            FileUtils.rm_f(@path)
          end

          teardown do
            FileUtils.chmod_R(0755, @dir)
          end

          test "writable" do
            FileUtils.chmod(0700, @dir)
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.blank?
            end
          end

          test "not writable" do
            FileUtils.chmod(0500, @dir)
            @fluentd.check_permission(@column)
            assert do
              @fluentd.errors.present?
            end
            assert_equal(I18n.t('activerecord.errors.messages.lack_write_permission'), @fluentd.errors[@column].first)
          end
        end
      end
    end
  end

  setup do
    @fluentd = FactoryBot.build(:fluentd)
  end

  teardown do
    File.unlink(Fluentd.json_path) if File.exist?(Fluentd.json_path)
  end

  sub_test_case "#valid?" do
    setup do
      %w(pid_file log_file config_file).each do |column|
        FileUtils.mkdir_p(File.dirname(@fluentd.__send__(column)))
        FileUtils.touch(@fluentd.__send__(column))
      end
    end

    data("fluentd" => ["fluentd_gem", true],
         "not declared in Fluentd.variants" => ["foobar", false])
    test "variant" do |(variant, result)|
      @fluentd.variant = variant
      assert_equal(result, @fluentd.valid?)
    end

    sub_test_case "pid_file" do
      def setup_target
        @column = :pid_file
        @path = @fluentd.pid_file
      end
      include PathPermission
    end

    sub_test_case "log_file" do
      def setup_target
        @column = :log_file
        @path = @fluentd.log_file
      end
      include PathPermission
    end

    sub_test_case "config_file" do
      def setup_target
        @column = :config_file
        @path = @fluentd.config_file
      end
      include PathPermission
    end
  end

  data("fluentd_gem" => { variant: "fluentd_gem", fluentd_gem?: true },
       "td-agent" => { variant: "td-agent", fluentd_gem?: false })
  test "variant" do |data|
    @fluentd.variant = data[:variant]
    assert_equal(data[:fluentd_gem?], @fluentd.fluentd_gem?)
    @fluentd.load_settings_from_agent_default
    expected = {
      pid_file: @fluentd.agent.class.default_options[:pid_file],
      log_file: @fluentd.agent.class.default_options[:log_file],
      config_file: @fluentd.agent.class.default_options[:config_file]
    }
    actual = {
      pid_file: @fluentd.pid_file,
      log_file: @fluentd.log_file,
      config_file: @fluentd.config_file,
    }
    assert_equal(expected, actual)
  end

  data("fluentd_gem" => ["fluentd_gem", Fluentd::Agent::FluentdGem],
       "td-agent" => ["td-agent", Fluentd::Agent::TdAgent])
  test "#agent" do |(variant, klass)|
    @fluentd.variant = variant
    assert do
      @fluentd.agent.instance_of?(klass)
    end
  end

  sub_test_case "#ensure_default_config_file" do
    setup do
      @config_file = Rails.root + "tmp/test.conf"
      @fluentd.config_file = @config_file
    end

    test "doesn't exist" do
      File.unlink(@config_file) if File.exist?(@config_file)
      @fluentd.save
      assert do
        File.exist?(@fluentd.config_file)
      end
    end

    test "already exist" do
      FileUtils.touch(@config_file)
      @fluentd.save
      assert do
        File.exist?(@fluentd.config_file)
      end
    end
  end
end
