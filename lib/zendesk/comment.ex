defmodule Zendesk.Comment do
  alias Zendesk.Ticket
  alias Zendesk.Client.{Operation, Result}
  alias __MODULE__

  defstruct [
    :attachments,
    :audit_id,
    :author_id,
    :body,
    :created_at,
    :html_body,
    :id,
    :metadata,
    :plain_body,
    :public,
    :type,
    :via
  ]

  @type t :: %__MODULE__{}

  @doc """
  Get a list of `Zendesk.Macro`s.

  If passed to `Zendesk.request!/1` it will return only the first results from the list.
  You can create a `Stream` to paginate over all results by calling `Zendesk.stream!/1`.

  For instance:

       # get 400 macros
       Zendesk.Macro.list()
       |> Zendesk.stream!()
       |> Stream.take(400)
       |> Enum.to_list()
       |> IO.inspect()
  """
  @spec list_for(Ticket.t()) :: Operation.t()
  def list_for(%Ticket{id: id}) do
    %Operation{path: "tickets/#{id}/comments.json", parser: &parse_list/1}
    |> Operation.with_page_size(1)
  end

  @doc false
  def parse(%Result{parsed: %{macro: macro}}), do: {:ok, struct(Macro, macro)}

  @doc false
  def parse_list(%Result{parsed: %{comments: comments}} = result) do
    list = Enum.map(comments, &struct(Comment, &1))
    {:ok, list, Result.to_streamable(result)}
  end
end
