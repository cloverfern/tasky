defmodule Tasky.LocalEmbeddingModel do
  use AshAi.EmbeddingModel

  @impl true
  def dimensions(_opts), do: 768

  @impl true
  def generate(texts, _opts) do
    headers = [
      {"Content-Type", "application/json"}
    ]

    body = %{
      "input" => texts,
      "model" => "text-embedding-nomic-embed-text-v1.5"
    }

    response =
      Req.post!("http://localhost:1234/v1/embeddings",
        json: body,
        headers: headers
      )

    case response.status do
      200 ->
        response.body["data"]
        |> Enum.map(fn %{"embedding" => embedding} -> embedding end)
        |> then(&{:ok, &1})

      _status ->
        {:error, response.body}
    end
  end
end
