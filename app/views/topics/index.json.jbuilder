json.array!(@topics) do |topic|
  json.extract! topic, :id, :description
  json.url topic_url(topic, format: :json)
end
