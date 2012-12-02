module Resque
  module Ffmpeg
    module Encoder
      class WebM < Base
        def preset_options
          {
            :size              => "640x480",
            :video_bitrate     => "600k",
            :audio_bitrate     => "128k",
            :audio_sample_rate => 44100,
            :other_options     => "-aq 3 -flags +loop -cmp +chroma -partitions +parti8x8+parti4x4+partp8x8+partp4x4 -me_method hex -subq 6 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -b_strategy 1 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -coder 0 -level 300 -async 2 -threads auto"
          }
        end

        def vcodec
          "libvpx"
        end

        def acodec
          "vorbis"
        end

        def format
          "webm"
        end
      end
    end
  end
end
