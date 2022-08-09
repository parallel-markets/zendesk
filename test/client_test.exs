defmodule Zendesk.ClientTest do
  use ExUnit.Case
  import Mock

  alias Zendesk.Client

  @test_token "thisisatestkeyanditisverylong"
  @test_email "test@example.com"
  @test_subdomain "example.com"

  setup do
    Application.put_env(:zendesk, :token, @test_token)
    Application.put_env(:zendesk, :email, @test_email)
    Application.put_env(:zendesk, :subdomain, @test_subdomain)
  end

  describe "When making GET requests" do
    test "Calling the API without a token should raise" do
      Application.delete_env(:zendesk, :token)
      msg = "You must configure a :token and :email for :zendesk"

      assert_raise RuntimeError, msg, fn ->
        Client.get("", [], %{})
      end
    end

    test "Query params and headers should be handled" do
      url = "http://example.com"

      with_mock HTTPoison,
        get: fn rurl, rheaders ->
          assert rurl == "#{url}?test=value"

          bearer = Base.encode64(@test_email <> "/token:" <> @test_token)

          assert rheaders == [
                   Authorization: "Basic #{bearer}",
                   Accept: "Application/json; Charset=utf-8",
                   "Content-Type": "application/json",
                   one: "two"
                 ]

          {:ok, %HTTPoison.Response{body: "body", status_code: 200}}
        end do
        assert Client.get(url, [one: "two"], test: "value") == {:ok, "body", []}
      end
    end
  end

  describe "When making POST requests" do
    test "Request body and headers should be handled" do
      url = "http://example.com"

      with_mock HTTPoison,
        post: fn rurl, rbody, rheaders ->
          assert rurl == url

          bearer = Base.encode64(@test_email <> "/token:" <> @test_token)

          assert rheaders == [
                   Authorization: "Basic #{bearer}",
                   Accept: "Application/json; Charset=utf-8",
                   "Content-Type": "application/json",
                   one: "two"
                 ]

          assert rbody == Jason.encode!(%{test: "value"})

          {:ok, %HTTPoison.Response{body: "body", status_code: 200}}
        end do
        assert Client.post(url, [one: "two"], %{test: "value"}) == {:ok, "body", []}
      end
    end
  end

  describe "When making PUT requests" do
    test "Request body and headers should be handled" do
      url = "http://example.com"

      with_mock HTTPoison,
        put: fn rurl, rbody, rheaders ->
          assert rurl == url

          bearer = Base.encode64(@test_email <> "/token:" <> @test_token)

          assert rheaders == [
                   Authorization: "Basic #{bearer}",
                   Accept: "Application/json; Charset=utf-8",
                   "Content-Type": "application/json",
                   one: "two"
                 ]

          assert rbody == Jason.encode!(%{test: "value"})

          {:ok, %HTTPoison.Response{body: "body", status_code: 200}}
        end do
        assert Client.put(url, [one: "two"], %{test: "value"}) == {:ok, "body", []}
      end
    end
  end
end
