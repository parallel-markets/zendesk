defmodule Zendesk.UserTest do
  use ExUnit.Case

  alias Zendesk.User
  alias Zendesk.Client.{Operation, Result}

  test "list should produce expected operation" do
    %Operation{path: path, type: :get, parser: parser} = User.list()
    assert path == "users.json"

    data = [%{id: 123}, %{id: 456}]
    op = %Operation{}
    result = %Result{parsed: %{users: data}, operation: op}

    {:ok, [one, two], streamable} = parser.(result)
    assert %User{id: 123} = one
    assert %User{id: 456} = two

    assert streamable.closed
    assert is_nil(streamable.cursor)
    assert streamable.operation == op
  end

  test "show by id should produce expected operation" do
    %Operation{path: path, type: :get, parser: parser} = User.show(123)
    assert path == "users/123.json"

    data = %{id: 123}
    op = %Operation{}
    result = %Result{parsed: %{user: data}, operation: op}

    assert {:ok, %User{id: 123}} = parser.(result)
  end
end
