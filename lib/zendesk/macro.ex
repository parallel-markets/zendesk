defmodule Zendesk.Macro do
  alias Zendesk.Ticket
  alias Zendesk.Client.{Operation, Result}
  alias __MODULE__

  defstruct [
    :actions,
    :active,
    :created_at,
    :description,
    :id,
    :position,
    :raw_title,
    :restriction,
    :title,
    :updated_at,
    :url
  ]

  @type t :: %__MODULE__{}

  @doc """
  Get a specific `Zendesk.Macro`.
  """
  @spec show(pos_integer()) :: Operation.t()
  def show(id), do: %Operation{path: "macros/#{id}.json", parser: &parse/1}

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
  @spec list() :: Operation.t()
  def list do
    %Operation{path: "macros.json", parser: &parse_list/1} |> Operation.with_page_size(1)
  end

  @doc """
  Returns the changes the macro would make to a ticket. It doesn't actually change a ticket.
  """
  @spec ticket_changes(Macro.t()) :: Operation.t()
  def ticket_changes(%Macro{id: id}) do
    %Operation{path: "macros/#{id}/apply.json", parser: &Ticket.parse/1}
  end

  @doc false
  def parse(%Result{parsed: %{macro: macro}}), do: {:ok, struct(Macro, macro)}

  @doc false
  def parse_list(%Result{parsed: %{macros: macros}} = result) do
    list = Enum.map(macros, &struct(Macro, &1))
    {:ok, list, Result.to_streamable(result)}
  end
end
