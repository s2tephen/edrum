json.array!(@sequences) do |sequence|
  json.extract! sequence, :id, :title, :artist, :default_bpm, :meter_top, :meter_bottom, :time
  json.url sequence_url(sequence, format: :json)
end
