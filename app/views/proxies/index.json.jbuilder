json.array!(@proxies) do |proxy|
  json.extract! proxy, :id
  json.url proxy_url(proxy, format: :json)
end
