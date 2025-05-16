defmodule Tasky.Work.Task do
  alias Phoenix.LiveViewTest.DOM
  use Ash.Resource, otp_app: :tasky, domain: Tasky.Work, data_layer: AshPostgres.DataLayer

  postgres do
    table "tasks"
    repo Tasky.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    integer_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :details, :string
    attribute :completed, :boolean

    attribute :priority, :string do
      constraints max_length: 20
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end
end
