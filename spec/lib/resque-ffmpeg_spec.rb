require "resque-ffmpeg"
require File.join(File.dirname(File.expand_path(__FILE__)), "..", "spec_helper")

describe Resque::Ffmpeg do
  sample_dir = File.join(File.dirname(File.expand_path(__FILE__)), "..", "samples")
  describe ".get_aspect" do
    subject { Resque::Ffmpeg.get_aspect("#{sample_dir}/sample_16_9.mp4") }

    it { should eq "16/9".to_r }
  end

  describe "#do_encode" do
    context "MP4" do
      subject(:encoder) { Resque::Ffmpeg::Encoder::MP4.new }

      describe "on_progress callback" do
        before do
          encoder.on_progress = Proc.new {|progress| true }
        end

        it "on_progress receive call" do
          encoder.on_progress.should_receive(:call).with(an_instance_of(Float)).at_least(:once)
          encoder.do_encode("#{sample_dir}/sample.mp4", "#{sample_dir}/output.mp4")
        end
      end

      describe "on_complete callback" do
        before do
          encoder.on_complete = Proc.new {|encoder| true }
        end

        it "on_complete receive call" do
          encoder.on_complete.should_receive(:call).with(encoder).once
          encoder.do_encode("#{sample_dir}/sample.mp4", "#{sample_dir}/output.mp4")
        end
      end
    end

    context "WebM" do
      subject(:encoder) { Resque::Ffmpeg::Encoder::WebM.new }

      describe "on_progress callback" do
        before do
          encoder.on_progress = Proc.new {|progress| true }
        end

        it "on_progress receive call" do
          encoder.on_progress.should_receive(:call).with(an_instance_of(Float)).at_least(:once)
          encoder.do_encode("#{sample_dir}/sample.mp4", "#{sample_dir}/output.webm")
        end
      end

      describe "on_complete callback" do
        before do
          encoder.on_complete = Proc.new {|encoder| true }
        end

        it "on_complete receive call" do
          encoder.on_complete.should_receive(:call).with(encoder).once
          encoder.do_encode("#{sample_dir}/sample.mp4", "#{sample_dir}/output.webm")
        end
      end
    end
  end
end

describe Resque::Ffmpeg::BaseJob do
  context "When job is performed" do
    class ::TestJob
      extend Resque::Ffmpeg::BaseJob
    end

    it "should receive do_encode" do
      input_filename = "#{sample_dir}/sample.mp4"
      output_filename = "#{sample_dir}/output.mp4"
      Resque::Ffmpeg::Encoder::MP4.any_instance.should_receive(:do_encode).with(input_filename, output_filename).once
      perform_job(::TestJob, input_filename, output_filename)
    end
  end

  context "Job class has on_progress method" do
    class ::ProgressJob
      extend Resque::Ffmpeg::BaseJob

      def self.on_progress(progress)
        true
      end
    end

    it "should receive on_progress" do
      input_filename = "#{sample_dir}/sample.mp4"
      output_filename = "#{sample_dir}/output.mp4"
      ::ProgressJob.should_receive(:on_progress).with(an_instance_of(Float)).at_least(:once)
      perform_job(::ProgressJob, input_filename, output_filename)
    end
  end

  context "Job class has on_complete method" do
    class ::CompleteJob
      extend Resque::Ffmpeg::BaseJob

      def self.on_complete(encoder)
        true
      end
    end

    it "should receive on_complete" do
      input_filename = "#{sample_dir}/sample.mp4"
      output_filename = "#{sample_dir}/output.mp4"
      ::CompleteJob.should_receive(:on_complete).with(an_instance_of(Resque::Ffmpeg::Encoder::MP4)).once
      perform_job(::CompleteJob, input_filename, output_filename)
    end
  end
end

