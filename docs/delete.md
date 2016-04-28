# Deleting stream

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
