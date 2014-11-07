json.array!(@notes) do |note|
  json.extract! note, :id, :bar, :beat, :duration, :drum
  json.url note_url(note, format: :json)
end
