# Respawn

Yet another gem to retry failed operations.

Documentation is not yet available, as the API is not yet stable.

Basic usage based on specs:

### Exception based retry

```ruby
Respawn::Try.call(:net, onfail: :raise) do
  Faraday.get("https://example.com")
end
```

### Use custom predicate logic to determine if a retry is needed.

```ruby
http_response = Data.define(:status, :body)

responses = [
  http_response.new(500, "error"),
  http_response.new(200, "error"),
  http_response.new(500, "error"),
  http_response.new(201, "created"),
]

predicates = [
  proc { it.status >= 500 },
  proc { it.body == "error" },
]

result =
  Respawn::Try.call(onfail: :handler, predicate: predicats) do |handler|
    handler.define do |exception|
      "This failed due to #{exception.class}"
    end

    responses[handler.retry_number]
  end

expect(result).to eq http_response.new(201, "created")
```
