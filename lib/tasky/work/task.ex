defmodule Tasky.Work.Task do
  alias Tasky.LocalEmbeddingModel
  require Ash.Resource.Change.Builtins
  require Ash.Query
  # alias Phoenix.LiveViewTest.DOM

  use Ash.Resource,
    otp_app: :tasky,
    domain: Tasky.Work,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAi, AshOban]

  postgres do
    table "tasks"
    repo Tasky.Repo
  end

  vectorize do
    full_text do
      text fn task ->
        """
        Title: #{task.title}
        Details: #{task.details}
        """
      end

      used_attributes [:title, :details]
    end

    strategy :ash_oban
    ash_oban_trigger_name :update_embeddings
    embedding_model LocalEmbeddingModel
  end

  oban do
    triggers do
      trigger :update_embeddings do
        action :ash_ai_update_embeddings
        worker_read_action :read
        worker_module_name __MODULE__.AshOban.Worker.UpdateEmbeddings
        scheduler_module_name __MODULE__.AshOban.Scheduler.UpdateEmbeddings
        scheduler_cron false
      end
    end
  end

  actions do
    defaults [:read, :destroy, create: [:title, :details, :priority]]

    read :search do
      argument :query, :string, allow_nil?: false

      prepare before_action(fn query, context ->
                IO.inspect(query)
                IO.inspect(context)

                case LocalEmbeddingModel.generate([query.arguments.query], []) do
                  {:ok, [search_vector]} ->
                    Ash.Query.filter(
                      query,
                      expr(
                        fragment(
                          "cosine_distance(?, ?::vector) < 0.5",
                          full_text_vector,
                          ^search_vector
                        )
                      )
                    )

                  {:error, error} ->
                    {:error, error}
                end
              end)
    end

    update :update do
      accept [:title, :details, :priority]
      require_atomic? false
    end
  end

  attributes do
    integer_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :details, :string

    attribute :completed, :boolean do
      allow_nil? false
      default false
    end

    attribute :priority, :string do
      constraints max_length: 20
      allow_nil? false
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end
end
