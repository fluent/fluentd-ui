require 'spec_helper'
require 'fileutils'

describe 'Fluentd::Agent::LocalCommon' do
  subject { target_class.new.tap{|t| t.pid_file = pid_file_path} }

  let!(:target_class) { Struct.new(:pid_file){ include Fluentd::Agent::LocalCommon } }
  let!(:pid_file_path) { Rails.root.join('tmp', 'fluentd-test', 'local_common_test.pid').to_s }

  describe '#pid' do
    context 'no pid file exists' do
      its(:pid) { should be_nil }
    end

    context 'empty pid file given' do
      before { FileUtils.touch pid_file_path }
      after  { FileUtils.rm pid_file_path }

      its(:pid) { should be_nil }
    end

    context 'valid pid file given' do
      before { File.write pid_file_path, '99999' }
      after  { FileUtils.rm pid_file_path }

      its(:pid) { should eq(99999) }
    end
  end
end
