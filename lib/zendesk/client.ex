defmodule Zendesk.Client do
  @moduledoc """
  Make requests to the API.

  The requests are made using `Zendesk.Client.Operation`s.
  """

  alias Zendesk.Client.{Operation, Result}

  @doc """
  Call the API with the given `Zendesk.Client.Operation`.
  """
  @spec request(Operation.t()) :: Parser.parsed_result()
  def request(%Operation{type: :get, path: path, parser: parser, params: params} = op) do
    path
    |> make_url()
    |> get([], params)
    |> case do
      {:ok, body, headers} ->
        parser.(Result.from_encoded(body, headers, op))

      error ->
        error
    end
  end

  def request(%Operation{type: :delete, path: path, parser: parser} = op) do
    with {:ok, body, headers} <- delete(make_url(path)) do
      parser.(Result.from_encoded(body, headers, op))
    end
  end

  def request(%Operation{type: :post, path: path, parser: parser, body: body} = op) do
    with {:ok, body, headers} <- post(make_url(path), body) do
      parser.(Result.from_encoded(body, headers, op))
    end
  end

  def request(%Operation{type: :put, path: path, parser: parser, body: body} = op) do
    with {:ok, body, headers} <- put(make_url(path), body) do
      parser.(Result.from_encoded(body, headers, op))
    end
  end

  @doc """
  Call the API with the given `Zendesk.Client.Operation`.

  This function throws an error if there was any issue calling the API.
  """
  @spec request!(Operation.t()) :: Parser.parsed_result()
  def request!(req) do
    case request(req) do
      {:ok, result} ->
        result

      {:ok, result, _streamable} ->
        result

      {:error, error} ->
        raise RuntimeError, message: error
    end
  end

  @doc """
  Make a GET request to the API at the given URL.
  """
  @spec get(String.t(), [{atom(), String.t()}], list()) ::
          {:ok, binary(), list()} | {:error, String.t()}
  def get(url, headers, params) do
    req_headers = add_default_headers(headers)

    url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> to_string()
    |> HTTPoison.get(req_headers)
    |> case do
      {:ok, %HTTPoison.Response{body: body, status_code: 200, headers: headers}} ->
        {:ok, body, headers}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "API returned #{code}"}

      {:error, error} ->
        {:error, HTTPoison.Error.message(error)}
    end
  end

  @doc """
  Make a DELETE request to the API at the given URL.
  """
  @spec delete(String.t(), [{atom(), String.t()}]) ::
          {:ok, binary(), list()} | {:error, String.t()}
  def delete(url, headers \\ []) do
    req_headers = add_default_headers(headers)

    case HTTPoison.delete(url, req_headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200, headers: headers}} ->
        {:ok, body, headers}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "API returned #{code}"}

      {:error, error} ->
        {:error, HTTPoison.Error.message(error)}
    end
  end

  @doc """
  Make a POST request to the API at the given URL.
  """
  @spec post(String.t(), [{atom(), String.t()}], map()) ::
          {:ok, binary(), list()} | {:error, String.t()}
  def post(url, headers \\ [], body) do
    req_headers = add_default_headers(headers, :post)
    req_body = Jason.encode!(body)

    case HTTPoison.post(url, req_body, req_headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: code, headers: headers}}
      when code in [200, 201] ->
        {:ok, body, headers}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "API returned #{code}"}

      {:error, error} ->
        {:error, HTTPoison.Error.message(error)}
    end
  end

  @doc """
  Make a PUT request to the API at the given URL.
  """
  @spec put(String.t(), [{atom(), String.t()}], map()) ::
          {:ok, binary(), list()} | {:error, String.t()}
  def put(url, headers \\ [], body) do
    req_headers = add_default_headers(headers, :put)
    req_body = Jason.encode!(body)

    case HTTPoison.put(url, req_body, req_headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200, headers: headers}} ->
        {:ok, body, headers}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "API returned #{code}"}

      {:error, error} ->
        {:error, HTTPoison.Error.message(error)}
    end
  end

  defp make_url("https://" <> _ = url), do: url

  defp make_url(path) do
    subdomain = Application.get_env(:zendesk, :subdomain)

    if is_nil(subdomain) do
      raise RuntimeError, message: "You must configure a :subdomain for :zendesk"
    end

    Path.join("https://#{subdomain}.zendesk.com/api/v2", path)
  end

  defp add_default_headers(headers, method \\ :get)

  defp add_default_headers(headers, :get) do
    Keyword.merge(
      [
        Authorization: "Basic " <> get_credentials(),
        Accept: "Application/json; Charset=utf-8"
      ],
      headers
    )
  end

  defp add_default_headers(headers, method) when method in [:post, :put] do
    Keyword.merge(
      [
        Authorization: "Basic " <> get_credentials(),
        Accept: "Application/json; Charset=utf-8",
        "Content-Type": "application/json"
      ],
      headers
    )
  end

  defp get_credentials do
    token = Application.get_env(:zendesk, :token)
    email = Application.get_env(:zendesk, :email)

    if is_nil(token) or is_nil(email) do
      raise RuntimeError, message: "You must configure a :token and :email for :zendesk"
    else
      Base.encode64(email <> "/token:" <> token)
    end
  end
end
