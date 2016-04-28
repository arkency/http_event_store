# Creating new event(s)

Creating a single event:

```ruby
stream_name = "order_1"
event_data = { event_type: "OrderCreated",
               data: { data: "sample" },
               event_id: "b2d506fd-409d-4ec7-b02f-c6d2295c7edd" }
client.append_to_stream(stream_name, event_data)
```

OR

```ruby
EventData = Struct.new(:data, :event_type)
stream_name = "order_1"
event_data = EventData.new({ data: "sample" }, "OrderCreated")
client.append_to_stream(stream_name, event_data)
```

Creating a single event with optimistic locking:

```ruby
stream_name = "order_1"
event_data = { event_type: "OrderCreated", data: { data: "sample" }}
expected_version = 1
client.append_to_stream(stream_name, event_data, expected_version)
```

Creating multiple events:

From version 3.x of the Event Store it´s possible to append more than one event in a request.

```ruby
stream_name = "order_1"
event_data_array = [{ event_type: "OrderCreated",
                      data: { data: "sample" },
                      event_id: "b2d506fd-409d-4ec7-b02f-c6d2295c7edd" },
                    { event_type: "OrderDeleted",
                      data: { data: "sample 2" },
                      event_id: "c2d506fd-409d-4ec7-b02f-c6d2295c7eda" }]
client.append_to_stream(stream_name, event_data_array)
```
