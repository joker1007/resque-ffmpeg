module Resque
  module Ffmpeg
    module Encoder
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
