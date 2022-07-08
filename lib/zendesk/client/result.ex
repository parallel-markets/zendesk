defmodule Zendesk.Client.Result do
  @moduledoc """
  This module is used to represent the result of an API call.

  It is passed to the parser specified in a given `Zendesk.Client.Operation` and the
  result is what's returned from an `Zendesk.Client.request/1`.
  """
  alias Zendesk.Client.{Operation, Streamable}
  alias __MODULE__

  defstruct [:body, :parsed, :operation, :headers]

  @type t :: %__MODULE__{
          body: binary(),
          parsed: map() | nil,
          operation: Operation.t(),
          headers: list()
        }

  @doc """
  Convert the raw results of an API call and turn them into a `Zendesk.Client.Result`.
  """
  @spec from_encoded(String.t(), list(), Operation.t()) :: Result.t()
  def from_encoded(body, headers, operation) when is_binary(body) do
    headers
    |> Enum.map(fn {k, v} -> {String.downcase(k), v} end)
    |> Enum.into(%{})
    |> Map.get("content-type")
    |> case do
      "application/json" <> _ ->
        %Result{
          body: body,
          parsed: Jason.decode!(body, keys: :atoms!),
          operation: operation,
          headers: headers
        }

      _ ->
        %Result{body: body, operation: operation, headers: headers}
    end
  end

  @doc """
  Convert the `Zendesk.Client.Result` of an API call and turn it into a `Zendesk.Client.Streamable`.

  This is used in cases where we expect the result to contain pagination.
  """
  @spec to_streamable(Result.t()) :: Streamable.t()
  def to_streamable(%Result{parsed: parsed, operation: op}) do
    cursor = extract_cursor(parsed)
    %Streamable{operation: op, cursor: cursor, closed: is_nil(cursor)}
  end

  defp extract_cursor(%{links: %{next: url}}) when is_binary(url) and byte_size(url) > 0 do
    url
    |> URI.parse()
    |> Map.get(:query)
    |> Kernel.||("")
    |> URI.decode_query()
    |> Map.get("page[after]")
  end

  defp extract_cursor(_), do: nil
end
