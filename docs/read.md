# Reading stream's event forward

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

# Reading stream's event backward

```ruby
stream_name = "order_1"
start = 21
count = 40
client.read_events_backward(stream_name, start, count)
```

# Reading all stream's event forward

This method allows us to load all stream's events ascending.

```ruby
stream_name = "order_1"
client.read_all_events_forward(stream_name)
```

# Reading all stream's event backward

This method allows us to load all stream's events descending.

```ruby
stream_name = "order_1"
client.read_all_events_backward(stream_name)
```
