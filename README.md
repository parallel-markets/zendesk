# Zendesk Elixir Library
[![Build Status](https://github.com/parallel-markets/zendesk/workflows/ci/badge.svg)](https://github.com/parallel-markets/zendesk)
[![Hex pm](http://img.shields.io/hexpm/v/zendesk.svg?style=flat)](https://hex.pm/packages/zendesk)
[![API Docs](https://img.shields.io/badge/api-docs-lightgreen.svg?style=flat)](https://hexdocs.pm/zendesk/)

This is an Elixir library for interacting with the [Zendesk](https://zendesk.com) platform.

## Installation
The package can be installed by adding `zendesk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zendesk, "~> 0.1"}
  ]
end
```

Check [Hex](https://hex.pm/packages/zendesk) to make sure you're using an up-to-date version number.

## Usage

You'll need a Zendesk user email and token to access the API (based on security recommendations from Zendesk, password authentication isn't supported).

```
config :zendesk, token: "asdf123", email: "someuser@example.com"
```
Then, you can build and send requests.

```elixir
# To stream all tickets, paginating behind the scenes:
Zendesk.Ticket.list()
|> Zendesk.stream!()
|> Stream.take(100)
|> Enum.to_list()

# To get a specific ticket by ID:
ticket = Zendesk.Ticket.show(123) |> Zendesk.request!()

# To get a specific user by ID:
user = Zendesk.User.show(123) |> Zendesk.request!()
```

See the [list of modules](https://hexdocs.pm/zendesk/api-reference.html#modules) for a list of the other types (Users, Tickets, Macros, etc) available.

## Running Tests

To run tests:

```shell
$ mix test
```

## Reporting Issues

Please report all issues [on github](https://github.com/parallel-markets/zendesk/issues).
