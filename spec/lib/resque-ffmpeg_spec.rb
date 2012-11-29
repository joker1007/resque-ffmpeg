require "resque-ffmpeg"

describe Resque::Ffmpeg do
  SAMPLE_DIR = File.join(File.dirname(File.expand_path(__FILE__)), "..", "samples")
  describe ".get_aspect" do
    subject { Resque::Ffmpeg.get_aspect("#{SAMPLE_DIR}/sample.mp4") }

    it { should eq "4/3".to_r }
  end

  describe "#do_encode" do
    subject(:encoder) { Resque::Ffmpeg::MP4.new }

    describe "on_progress callback" do
      before do
        encoder.on_progress = Proc.new {|progress| true }
      end

      it "on_progress receive call" do
        encoder.on_progress.should_receive(:call).with(an_instance_of(Float)).at_least(:once)
        encoder.do_encode("#{SAMPLE_DIR}/sample.mp4", "#{SAMPLE_DIR}/output.mp4")
      end
    end
  end
end
