defmodule Zendesk.User do
  alias Zendesk.Client.{Operation, Result}
  alias __MODULE__

  defstruct [
    :user_fields,
    :id,
    :ticket_restriction,
    :report_csv,
    :moderator,
    :role_type,
    :url,
    :last_login_at,
    :signature,
    :updated_at,
    :created_at,
    :alias,
    :shared_phone_number,
    :default_group_id,
    :restricted_agent,
    :authenticity_token,
    :time_zone,
    :shared_agent,
    :shared,
    :tags,
    :verified,
    :phone,
    :details,
    :locale_id,
    :suspended,
    :two_factor_auth_enabled,
    :only_private_comments,
    :iana_time_zone,
    :notes,
    :locale,
    :custom_role_id,
    :email,
    :active,
    :role,
    :organization_id,
    :name,
    :external_id,
    :photo
  ]

  @type t :: %__MODULE__{}

  def search(query) when is_binary(query) do
    %Operation{path: "users/search.json", parser: &parse_list/1, params: [query: query]}
  end

  @doc """
  Get a list of `Zendesk.User`s.

  If passed to `Zendesk.request!/1` it will return only the first results from the list.
  You can create a `Stream` to paginate over all results by calling `Zendesk.stream!/1`.

  For instance:

       # get 400 users
       Zendesk.User.list()
       |> Zendesk.stream!()
       |> Stream.take(400)
       |> Enum.to_list()
       |> IO.inspect()
  """
  @spec list() :: Operation.t()
  def list(params \\ []) do
    Operation.with_page_size(%Operation{path: "users.json", params: params, parser: &parse_list/1})
  end

  @doc """
  Get a specific `Zendesk.User`.
  """
  @spec show(String.t()) :: Operation.t()
  def show(id), do: %Operation{path: "users/#{id}.json", parser: &parse/1}

  @doc """
  Delete a specific `Zendesk.User`.
  """
  @spec delete(String.t() | User.t()) :: Operation.t()
  def delete(%User{id: id}), do: delete(id)

  def delete(id), do: %Operation{type: :delete, path: "users/#{id}.json", parser: &parse/1}

  @doc """
  Permanently delete a specific `Zendesk.User`.

  Note that `Zendesk.User.delete/1` must be called first for this user.
  """
  @spec permanently_delete(String.t() | User.t()) :: Operation.t()
  def permanently_delete(%User{id: id}), do: permanently_delete(id)

  def permanently_delete(id) do
    %Operation{type: :delete, path: "deleted_users/#{id}.json", parser: &parse_deleted/1}
  end

  @doc """
  Get information for the specific `Zendesk.User` whose credentials are being used.
  """
  @spec get_requestor :: Operation.t()
  def get_requestor, do: %Operation{path: "users/me.json", parser: &parse/1}

  @doc false
  def parse(%Result{parsed: %{user: user}}), do: {:ok, struct(User, user)}

  @doc false
  def parse_deleted(%Result{parsed: %{deleted_user: user}}), do: {:ok, struct(User, user)}

  @doc false
  def parse_list(%Result{parsed: %{users: users}} = result) do
    list = Enum.map(users, &struct(User, &1))
    {:ok, list, Result.to_streamable(result)}
  end
end
