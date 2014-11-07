json.array!(@sessions) do |session|
  json.extract! session, :id, :score
  json.url session_url(session, format: :json)
end
