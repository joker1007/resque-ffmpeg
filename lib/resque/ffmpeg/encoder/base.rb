module Resque
  module Ffmpeg
    module Encoder
      class Base
        attr_reader :size, :video_bitrate, :audio_bitrate, :audio_sample_rate, :other_options
        attr_reader :input_filename, :output_filename
        attr_reader :on_progress, :on_complete

        def initialize(options = {})
          raise ArgumentError unless options.is_a?(Hash)
          merged_options = preset_options.merge(options)
          @size              = merged_options[:size]
          @aspect            = merged_options[:aspect]
          @video_bitrate     = merged_options[:video_bitrate]
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

        def vcodec
          raise NotImplementedError
        end

        def acodec
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
          ffmpeg -y -i '#{@input_filename}' -f #{format} -s #{size} -aspect #{aspect(@input_filename)} -vcodec #{vcodec} -b:v #{video_bitrate} -acodec #{acodec} -ar #{audio_sample_rate} -b:a #{audio_bitrate} #{other_options} #{@output_filename}
          CMD
          cmd.strip!

          if ENV["DEBUG"]
            Resque::Ffmpeg.logger.debug(cmd)
          end

          duration = nil
          time = nil
          progress = nil
          ffmpeg = IO.popen("#{cmd} 2>&1")
          ffmpeg.each_line do |line|
            if line =~ /Duration:(\s.?(\d*):(\d*):(\d*)\.(\d*))/
              duration = $2.to_i * 3600 + $3.to_i * 60 + $4.to_i
            end

            if line =~ /frame=.*time=(\s*(\d*):(\d*):(\d*)\.(\d*))/
              time = $2.to_i * 3600 + $3.to_i * 60 + $4.to_i
            end

            if duration && time
              progress = (time / duration.to_f)
              on_progress.call(progress) if on_progress
            end
          end

          on_complete.call(self) if on_complete
        end
      end
    end
  end
end
