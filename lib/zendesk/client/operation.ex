defmodule Zendesk.Client.Operation do
  @moduledoc """
  A description of a specific API call.
  """
  alias Zendesk.Client.Parser
  alias __MODULE__

  defstruct path: "/", type: :get, parser: &Parser.default_parse/1, params: [], body: nil

  @type operation_type :: :get | :post | :patch | :put | :delete

  @type t :: %__MODULE__{
          path: String.t(),
          type: operation_type(),
          parser: Parser.parser_func(),
          params: Keyword.t(),
          body: map() | nil
        }

  @doc """
  Add a page size to the `Operation` to enforce a cursor style pagination of the result.
  """
  @spec with_page_size(Operation.t(), non_neg_integer()) :: Operation.t()
  def with_page_size(%Operation{params: params} = op, size \\ 100) do
    %{op | params: Keyword.put(params, :"page[size]", size)}
  end
end
