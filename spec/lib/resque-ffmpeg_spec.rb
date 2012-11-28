require "resque-ffmpeg"

describe Resque::Ffmpeg do
  it "get_aspect" do
    Resque::Ffmpeg.get_aspect("~/Dropbox/pasokara_test_data/BigBuckBunny_640x360.mp4").should eq "16/9".to_r
  end

  it "do_encode" do
    Resque::Ffmpeg::MP4.new.do_encode("~/Dropbox/pasokara_test_data/sm12312684/sm12312684.mp4", "~/test.mp4")
  end
end
