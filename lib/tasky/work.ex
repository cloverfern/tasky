defmodule Tasky.Work do
  use Ash.Domain,
    otp_app: :tasky

  resources do
    resource Tasky.Work.Task do
      define :create_task, action: :create
      define :get_task_by_id, action: :read, get_by: :id
      define :read_task, action: :read
      define :update_task, action: :update
      define :destroy_task, action: :destroy
      define :semantic_search, action: :search
    end
  end
end
