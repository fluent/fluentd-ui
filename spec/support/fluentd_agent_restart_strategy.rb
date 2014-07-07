shared_examples_for "Restart strategy" do
      before { instance.stub(:running?).and_return(running) }
      subject { instance.restart }

  context "not running" do
    before { instance.stub(:start).and_return(start) }

    let(:running) { false }

    context "#start success" do
      let(:start) { true }
      it { should be_truthy }
    end

    context "#start failed" do
      let(:start) { false }
      it { should be_falsy }
    end
  end

  context "running" do
    before { instance.stub(:stop).and_return(stop_result) }
    before { instance.stub(:start).and_return(start_result) }
    before { instance.stub(:validate_fluentd_options).and_return(validate_result) }

    let(:running) { true }

    describe "return true only if #stop and #start success" do
      context "#validate_fluentd_options success" do
        let(:validate_result) { true }

        context "#stop success" do
          let(:stop_result) { true }

          context" #start success" do
            let(:start_result) { true }
            it { should be_truthy }
          end

          context" #start fail" do
            let(:start_result) { false }
            it { should be_falsy }
          end
        end

        context "#stop fail" do
          let(:stop_result) { false }

          context" #start success" do
            let(:start_result) { true }
            it { should be_falsy }
          end

          context" #start fail" do
            let(:start_result) { false }
            it { should be_falsy }
          end
        end
      end

      context "#validate_fluentd_options failed" do
        let(:validate_result) { false }

        context "#stop success" do
          let(:stop_result) { true }

          context" #start success" do
            let(:start_result) { true } 
            it { should be_falsy }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_falsy }
          end
        end

        context "#stop fail" do
          let(:stop_result) { false } 

          context" #start success" do
            let(:start_result) { true } 
            it { should be_falsy }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_falsy }
          end
        end
      end
    end
  end
end
