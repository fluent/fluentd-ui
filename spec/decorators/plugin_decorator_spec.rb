require 'spec_helper'

describe PluginDecorator do
  let(:decorated_plugin) { build(:plugin).decorate }

  describe "#status" do
    subject { decorated_plugin.status }

    context "plugin is processing" do
      before { decorated_plugin.stub(:processing?).and_return(true) }

      it "returns the term for processing" do
        expect(subject).to eq I18n.t("terms.processing")
      end
    end

    context "plugin isn't while processing" do
      before { decorated_plugin.stub(:processing?).and_return(false) }

      context "plugin is already installed" do
        before { decorated_plugin.stub(:installed?).and_return(true) }

        it "returns the term for installed" do
          expect(subject).to eq I18n.t("terms.installed")
        end
      end

      context "plugin isn't installed yet" do
        before { decorated_plugin.stub(:installed?).and_return(false) }

        it "returns the term for not installed" do
          expect(subject).to eq I18n.t("terms.not_installed")
        end
      end
    end
  end
end
