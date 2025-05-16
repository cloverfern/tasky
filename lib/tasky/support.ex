defmodule Tasky.Support do
  use Ash.Domain,
    otp_app: :tasky

  resources do
    resource Tasky.Support.Ticket
    resource Tasky.Support.Representative
  end
end
