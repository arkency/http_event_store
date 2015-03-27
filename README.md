# HttpEventstore

HttpEventstore is a HTTP connector to the Greg's [Event Store](https://geteventstore.com/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_eventstore'
```

## Usage

To communicate with ES you have to create instance of `HttpEventstore::Connection` class. After configuring a client, you can do the following things.
 
```
#!ruby
client = HttpEventstore::Connection.new do |config|
   #default value is '127.0.0.1'
   config.endpoint = 'your_endpoint'
   #default value is 2113
   config.port = 'your_port'
   #default value is 20 entries per page
   config.page_size = 'your_page_size'
end
```

#### Creating new event

Creating a single event:

```
#!ruby
stream_name = "order_1"
event_data = { event_type: "OrderCreated",
               data: { data: "sample" },
               event_id: "b2d506fd-409d-4ec7-b02f-c6d2295c7edd" }
client.append_to_stream(stream_name, event_data)
```

OR

```
#!ruby
EventData = Struct.new(:data, :event_type)
stream_name = "order_1"
event_data = EventData.new({ data: "sample" }, "OrderCreated")
client.append_to_stream(stream_name, event_data)
```

Creating a single event with optimistic locking:

```
#!ruby
stream_name = "order_1"
event_data = { event_type: "OrderCreated", data: { data: "sample" }}
expected_version = 1
client.append_to_stream(stream_name, event_data, expected_version)
```

#### Deleting stream

The soft delete of single stream:

```ruby
stream_name = "order_1"
client.delete_stream("stream_name")
```

The hard delete of single stream:

```ruby
stream_name = "order_1"
hard_delete = true
client.delete_stream("stream_name", hard_delete)
```

The soft delete cause that you will be allowed to recreate the stream by creating new event. If you recreate soft deleted stream all events are lost.
After an hard delete any try to load the stream or create event will result in a 410 response.

#### Reading stream's event forward

```ruby
stream_name = "order_1"
start = 21
count = 40
client.read_events_forward(stream_name, start, count)
```

If you call following method to get the newest entries and no data is available the server wait some specified period of time.

```ruby
stream_name = "order_1"
start = 21
count = 40
pool_time = 15
client.read_events_forward(stream_name, start, count, poll_time)
```

#### Reading stream's event backward

```ruby
stream_name = "order_1"
start = 21
count = 40
client.read_events_backward(stream_name, start, count)
```

#### Reading all stream's event forward

This method allows us to load all stream's events ascending.

```ruby
stream_name = "order_1"
client.read_all_events_forward(stream_name)
```

#### Reading all stream's event backward

This method allows us to load all stream's events descending.

```ruby
stream_name = "order_1"
client.read_all_events_backward(stream_name)
```

## Supported version's of Event Store

To take advantage of all the functionality offered by our gem the minimum recommended version of Event Store is **2.1**

## Contributing

1. Fork it ( https://github.com/[my-github-username]/http_eventstore/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
