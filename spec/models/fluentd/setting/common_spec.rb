require 'spec_helper'

describe Fluentd::Setting::Common do
  let(:klass) { Fluentd::Setting::Common }

  describe "class methods" do
    describe "#booleans" do
      subject do
        Class.new do
          include Fluentd::Setting::Common
          attr_accessor :bool1, :bool2, :foo
          booleans :bool1, :bool2
        end.new
      end

      it { subject.column_type(:bool1).should == :boolean }
      it { subject.column_type(:bool2).should == :boolean }
      it { subject.column_type(:foo).should_not == :boolean }
    end

    describe "#flags" do
      subject do
        Class.new do
          include Fluentd::Setting::Common
          attr_accessor :flag1, :flag2, :foo
          flags :flag1, :flag2
        end.new
      end

      it { subject.column_type(:flag1).should == :flag }
      it { subject.column_type(:flag2).should == :flag }
      it { subject.column_type(:foo).should_not == :flag }
    end

    describe "#hidden" do
      subject do
        Class.new do
          include Fluentd::Setting::Common
          attr_accessor :hide
          hidden :hide
        end.new
      end

      it { subject.column_type(:hide).should == :hidden }
    end

    describe "#choice" do
      subject do
        Class.new do
          include Fluentd::Setting::Common
          attr_accessor :choice, :foo
          choice :choice, %w(a b c)
        end.new
      end

      it { subject.column_type(:choice).should == :choice }
      it { subject.values_of(:choice).should == %w(a b c) }
      it { subject.column_type(:foo).should_not == :choice }
    end

    describe "#nested" do
      before do
        @child_class = Class.new do
          include Fluentd::Setting::Common
        end
      end

      subject do
        child = @child_class
        Class.new do
          include Fluentd::Setting::Common
          attr_accessor :child, :foo
          nested :child, child
        end.new
      end

      it { subject.column_type(:child).should == :nested }
      it { subject.child_class(:child).should == @child_class }
      it { subject.column_type(:foo).should_not == :nested }
    end
  end

  describe "instance methods" do
    describe "plugin name" do
      before do
        klass = Class.new do
          include Fluentd::Setting::Common
        end
        Object.const_set(class_name, klass)
      end
      after { Object.send(:remove_const, class_name) }
      subject { Object.const_get(class_name).new }

      context "InFoo" do
        let(:class_name) { "InFoo" }
        it "plugin_type_name == foo" do
          subject.plugin_type_name.should == "foo"
        end
        it "should be input_plugin" do
          subject.should be_input_plugin
        end
      end

      context "OutBar" do
        let(:class_name) { "OutBar" }
        it "plugin_type_name == bar" do
          subject.plugin_type_name.should == "bar"
        end
        it "should be output_plugin" do
          subject.should be_output_plugin
        end
      end
    end

    describe "generate config file" do
      before do
        class Child
          include Fluentd::Setting::Common
          KEYS = [:child_foo]
          attr_accessor(*KEYS)
        end
        @klass = Class.new do
          include Fluentd::Setting::Common
          const_set(:KEYS, [:key1, :key2, :flag1, :hide, :ch, :child, :string])
          attr_accessor(*const_get(:KEYS))
          booleans :key1, :key2
          flags :flag1
          hidden :hide
          choice :ch, %w(foo bar)
          nested :child, Child
        end
      end
      after { Object.send(:remove_const, :Child) }

      subject { @klass.new(params).to_config("dummy") }

      describe "boolean" do
        # NOTE: "true" and "false" are the string because the are given by HTTP request
        let(:params) { {key1: "true", key2: "false"} }

        it { should include("key1 true\n") }
        it { should include("key2 false\n") }
      end

      describe "flag" do
        context "true" do
          let(:params) { {flag1: "true"} }
          it { should include("flag1\n") }
        end
        context "false" do
          let(:params) { {flag1: "false"} }
          it { should_not include("flag1\n") }
        end
      end

      describe "hidden" do
        let(:params) { {hide: "foo"} }
        it { should include("hide foo\n") }
      end

      describe "choice" do
        let(:params) { {ch: "foo"} }
        it { should include("ch foo\n") }
      end

      describe "string" do
        let(:params) { {string: "foobar"} }
        it { should include("string foobar\n") }
      end

      describe "nested" do
        let(:params) { {child: {"0" => { child_foo: "hi" }}} }
        it { should match(%r!<child>\n\s+child_foo hi\n\s+</child>!) }
      end
    end
  end
end

