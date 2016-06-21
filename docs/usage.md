# Usage

To communicate with ES you have to create instance of `HttpEventStore::Connection` class. After configuring a client, you can do the following things.

```ruby
client = HttpEventStore::Connection.new do |config|
  # default value is '127.0.0.1'
  config.endpoint = 'your_endpoint'
  # default value is 2113
  config.port = 'your_port'
  # default value is 20 entries per page
  config.page_size = 'your_page_size'
end
```
