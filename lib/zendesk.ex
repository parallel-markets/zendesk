defmodule Zendesk do
  @moduledoc """
  This is an Elixir library for interacting with the [Zendesk](https://zendesk.com) platform.

  It handles streaming paginated lists of tickets and users, and allows you to interact with the API
  with only a thin layer of Elixiry abstraction.
  """

  alias Zendesk.Client

  @doc """
  Send a given `Zendesk.Client.Operation` to the API endpoint.  

  This is the general entry point for all requests.
  """
  @spec request(Client.Operation.t()) :: Client.Parser.parsed_result()
  defdelegate request(req), to: Zendesk.Client

  @doc """
  Send a given `Zendesk.Client.Operation` to the API endpoint, raising if there's any error.
  """
  @spec request!(Client.Operation.t()) :: struct()
  defdelegate request!(req), to: Zendesk.Client

  @doc """
  Make a request, producing a `Stream` for paginating results.

  Send a given `Zendesk.Client.Operation` to the API endpoint with the expectation that the
  `Zendesk.Client.Operation` will produce a paginated result.  Any errors will raise an
  exception.
  """
  @spec stream!(Client.Operation.t()) :: Enumerable.t()
  defdelegate stream!(req), to: Zendesk.Client.Streamable
end
