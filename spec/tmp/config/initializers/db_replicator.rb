DbReplicator.configure do |config|
  # The proxy_host is a server that can connect to your production db.
  config.proxy_host = 'www.example.com'
end
