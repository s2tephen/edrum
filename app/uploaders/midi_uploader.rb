class MidiUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/midis"
  end

  def extension_white_list
    %w(mid)
  end
end
