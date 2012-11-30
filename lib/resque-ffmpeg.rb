require "resque-ffmpeg/version"

module Resque
  module Ffmpeg
    class << self
      def get_aspect(filename)
        return nil unless filename

        aspect = nil
        ffmpeg = IO.popen("ffmpeg -i '#{filename}' 2>&1")
        ffmpeg.each("\r") do |line|
          if line =~ /Stream.*Video.*, (\d+)x(\d+)[,\s]/
            aspect = "#{$1}/#{$2}".to_r
          end
        end
        aspect
      end
    end

    module BaseJob
      def perform(input_filename, output_filename, format = :mp4)
        encoder = Encoder::MP4.new
        encoder.do_encode(input_filename, output_filename)
      end
    end

    module Encoder
      class Base
        attr_reader :size, :vcodec, :video_bitrate, :acodec, :audio_bitrate, :audio_sample_rate, :other_options
        attr_reader :input_filename, :output_filename
        attr_reader :on_progress, :on_complete

        def initialize(options = {})
          raise ArgumentError unless options.is_a?(Hash)
          merged_options = preset_options.merge(options)
          @size              = merged_options[:size]
          @aspect            = merged_options[:aspect]
          @vcodec            = merged_options[:vcodec]
          @video_bitrate     = merged_options[:video_bitrate]
          @acodec            = merged_options[:acodec]
          @audio_bitrate     = merged_options[:audio_bitrate]
          @audio_sample_rate = merged_options[:audio_sample_rate]
          @other_options     = merged_options[:other_options]
        end

        def preset_options
          {}
        end

        def format
          raise NotImplementedError
        end

        def aspect(filename = nil)
          @aspect || Resque::Ffmpeg.get_aspect(filename)
        end

        def on_progress=(progress_proc)
          raise ArgumentError unless progress_proc.is_a?(Proc)
          @on_progress = progress_proc
        end

        def on_complete=(complete_proc)
          raise ArgumentError unless complete_proc.is_a?(Proc)
          @on_complete = complete_proc
        end

        def do_encode(input, output)
          @input_filename = input
          @output_filename = output
          cmd = <<-CMD
          ffmpeg -y -i '#{@input_filename}' -f #{format} -s #{size} -aspect #{aspect(@input_filename)} -vcodec #{vcodec} -b:v #{video_bitrate} -acodec #{acodec} -ar #{audio_sample_rate} -b:a #{audio_bitrate} -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partp4x4 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -maxrate 1000k -coder 0 -level 30 -async 2 -threads 4 #{@output_filename}
          CMD
          cmd.strip!
          duration = nil
          time = nil
          progress = nil
          ffmpeg = IO.popen("#{cmd} 2>&1")
          ffmpeg.each("\r") do |line|
            if line =~ /Duration:(\s.?(\d*):(\d*):(\d*)\.(\d*))/
              duration = $2.to_i * 3600 + $3.to_i * 60 + $4.to_i
            end

            if line =~ /frame=.*time=(\s*(\d*):(\d*):(\d*)\.(\d*))/
              time = $2.to_i * 3600 + $3.to_i * 60 + $4.to_i
            end

            if time && duration
              progress = (time / duration.to_f)
              on_progress.call(progress) if on_progress
            end
          end

          on_complete.call(self) if on_complete
        end
      end

      class MP4 < Base
        def preset_options
          {
            :size => "640x480",
            :video_bitrate => "600k",
            :audio_bitrate => "128k",
            :audio_sample_rate => 44100
          }
        end

        def vcodec
          "libx264"
        end

        def acodec
          "libfaac"
        end

        def format
          "mp4"
        end
      end
    end
  end
end
