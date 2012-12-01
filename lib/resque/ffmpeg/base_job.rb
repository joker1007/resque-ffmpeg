module Resque
  module Ffmpeg
    module BaseJob
      def self.extended(base)
        if base.respond_to?(:on_progress)
        end
      end

      def perform(input_filename, output_filename, format = :mp4)
        encoder = Encoder::MP4.new

        if respond_to?(:on_progress)
          encoder.on_progress = Proc.new {|progress| on_progress(progress)}
        end

        if respond_to?(:on_complete)
          encoder.on_complete = Proc.new {|enc| on_complete(enc)}
        end

        encoder.do_encode(input_filename, output_filename)
      end
    end
  end
end
