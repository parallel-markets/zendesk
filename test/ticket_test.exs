defmodule Zendesk.TicketTest do
  use ExUnit.Case

  alias Zendesk.Ticket
  alias Zendesk.Client.{Operation, Result}

  test "list should produce expected operation" do
    %Operation{path: path, type: :get, parser: parser} = Ticket.list()
    assert path == "tickets.json"

    data = [%{id: 123}, %{id: 456}]
    op = %Operation{}
    result = %Result{parsed: %{tickets: data}, operation: op}

    {:ok, [one, two], streamable} = parser.(result)
    assert %Ticket{id: 123} = one
    assert %Ticket{id: 456} = two

    assert streamable.closed
    assert is_nil(streamable.cursor)
    assert streamable.operation == op
  end

  test "show by id should produce expected operation" do
    %Operation{path: path, type: :get, parser: parser} = Ticket.show(123)
    assert path == "tickets/123.json"

    data = %{id: 123}
    op = %Operation{}
    result = %Result{parsed: %{ticket: data}, operation: op}

    assert {:ok, %Ticket{id: 123}} = parser.(result)
  end

  test "create should produce expected operation" do
    data = %{submitter_id: 1}
    %Operation{path: path, type: :post, parser: parser} = Ticket.create(data)
    assert path == "tickets.json"

    op = %Operation{}
    result = %Result{parsed: %{ticket: data}, operation: op}

    assert {:ok, %Ticket{submitter_id: 1}} = parser.(result)
  end

  test "update should produce expected operation" do
    ticket = %Ticket{id: 1}
    data = %{status: "complete"}
    %Operation{path: path, type: :put, parser: parser} = Ticket.update(ticket, data)
    assert path == "tickets/1.json"

    op = %Operation{}
    result = %Result{parsed: %{ticket: data}, operation: op}

    assert {:ok, %Ticket{status: "complete"}} = parser.(result)
  end

  test "create_comment should produce expected operation" do
    ticket = %Ticket{id: 1}
    data = %{body: "test"}

    %Operation{path: path, type: :put, parser: parser, body: body} =
      Ticket.create_comment(ticket, data)

    assert path == "tickets/1.json"
    assert body == %{ticket: %{comment: %{body: "test"}}}

    op = %Operation{}
    result = %Result{parsed: body, operation: op}

    assert {:ok, %Ticket{}} = parser.(result)
  end
end
