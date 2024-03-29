defmodule Zendesk.Ticket do
  alias Zendesk.{Comment, Macro}
  alias Zendesk.Client.{Operation, Result}
  alias __MODULE__

  defstruct [
    :updated_at,
    :status,
    :sharing_agreement_ids,
    :submitter_id,
    :id,
    :due_at,
    :custom_fields,
    :type,
    :email_cc_ids,
    :followup_ids,
    :problem_id,
    :allow_channelback,
    :created_at,
    :requester_id,
    :subject,
    :allow_attachments,
    :recipient,
    :raw_subject,
    :priority,
    :brand_id,
    :forum_topic_id,
    :organization_id,
    :assignee_id,
    :via,
    :group_id,
    :follower_ids,
    :collaborator_ids,
    :description,
    :url,
    :satisfaction_rating,
    :has_incidents,
    :is_public,
    :tags,
    :external_id
  ]

  @type t :: %__MODULE__{}

  @doc """
  Get a specific `Zendesk.Ticket`.
  """
  @spec show(pos_integer()) :: Operation.t()
  def show(id), do: %Operation{path: "tickets/#{id}.json", parser: &parse/1}

  @doc """
  Get a list of `Zendesk.Ticket`s.

  If passed to `Zendesk.request!/1` it will return only the first results from the list.
  You can create a `Stream` to paginate over all results by calling `Zendesk.stream!/1`.

  For instance:

       # get 400 tickets
       Zendesk.Ticket.list()
       |> Zendesk.stream!()
       |> Stream.take(400)
       |> Enum.to_list()
       |> IO.inspect()
  """
  @spec list() :: Operation.t()
  def list do
    Operation.with_page_size(%Operation{path: "tickets.json", parser: &parse_list/1})
  end

  @doc """
  Create a `Ticket` with the given parameters.
  """
  @spec create(map()) :: Operation.t()
  def create(ticket_params) do
    %Operation{
      type: :post,
      path: "tickets.json",
      parser: &parse/1,
      body: %{ticket: ticket_params}
    }
  end

  @doc """
  Update a `Ticket` with the given parameters.
  """
  @spec update(Ticket.t() | integer(), map()) :: Operation.t()
  def update(%Ticket{id: ticket_id}, ticket_params) do
    %Operation{
      type: :put,
      path: "tickets/#{ticket_id}.json",
      parser: &parse/1,
      body: %{ticket: ticket_params}
    }
  end

  @doc """
  Returns the full ticket object as it would be after applying the macro to the ticket.

  It doesn't actually change the ticket.
  """
  @spec after_changes(Ticket.t(), Macro.t()) :: Operation.t()
  def after_changes(%Ticket{id: ticket_id}, %Macro{id: macro_id}) do
    %Operation{path: "tickets/#{ticket_id}/macros/#{macro_id}/apply.json", parser: &parse/1}
  end

  @doc """
  Get `Comment`s for the given `Ticket`.
  """
  @spec get_comments(Ticket.t()) :: Operation.t()
  def get_comments(%Ticket{} = ticket), do: Comment.list_for(ticket)

  @doc """
  Create a `Comment` for the given `Ticket`.
  """
  @spec create_comment(Ticket.t(), map()) :: Operation.t()
  def create_comment(%Ticket{} = ticket, comment_params),
    do: Comment.create_for(ticket, comment_params)

  @doc false
  def parse(%Result{parsed: %{result: %{ticket: ticket}}}), do: {:ok, struct(Ticket, ticket)}

  @doc false
  def parse(%Result{parsed: %{ticket: ticket}}), do: {:ok, struct(Ticket, ticket)}

  @doc false
  def parse_list(%Result{parsed: %{tickets: tickets}} = result) do
    list = Enum.map(tickets, &struct(Ticket, &1))
    {:ok, list, Result.to_streamable(result)}
  end
end
