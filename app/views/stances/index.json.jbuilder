json.array!(@stances) do |stance|
  json.extract! stance, :id
  json.url stance_url(stance, format: :json)
end
