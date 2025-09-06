# Respawn

Yet another gem to retry failed operations.

Documentation is not yet available, as the API is not yet stable.

Call `Respawn.try { ... }` with a block of code to retry the logic if the code
raises network/io related exception. Method `.try` accepts set of parameters,
with the most important (and their corresponding defaults) being:

- `tries: 5` How many times the code in block will be retried in case
of detected failure. This is total number of tries, including the first
one. Setting this value to 1 will cause the logic to be executed only once.

- `wait: 0.5` How much time (in seconds) to wait between retries.

- `exs: [...]` List of exceptions which should be rescued for retry.
By default ...

Basic usage based on specs:

### Exception based retry

```ruby
Respawn.try do
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
  Respawn.try(onfail: :handler, predicate: predicats) do |handler|
    handler.define do |exception|
      "This failed due to #{exception.class}"
    end

    responses[handler.retry_number]
  end

expect(result).to eq http_response.new(201, "created")
```
