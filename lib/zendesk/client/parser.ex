defmodule Zendesk.Client.Parser do
  @moduledoc """
  This module contains functions used in parsing the results of API calls.

  In this context, "parsing" occurs after JSON responses have been decoded into a `Map` with atom keys.
  """
  alias Zendesk.Client.Result

  @typedoc """
  A single result from a parsed API call.
  """
  @type parsed_single_result :: {:ok, struct()} | {:error, String.t()}

  @typedoc """
  A result from a parsed API call that is streamable (i.e., a pagninated list).
  """
  @type parsed_list_result :: {:ok, list(struct()), Streamable.t()} | {:error, String.t()}

  @typedoc """
  Either a single or list result.
  """
  @type parsed_result :: parsed_single_result | parsed_list_result

  @type parser_func :: (Result.t() -> parsed_result)

  @doc """
  Provide a default parser in case an `Zendesk.Client.Operation` doesn't specify one.

  This just returns the body of the response.  This is useful for downloading files, for
  instance, where there's no transformation that should be done on the result.
  """
  @spec default_parse(Result.t()) :: parsed_result()
  def default_parse(%Result{body: body}), do: {:ok, body}
end
