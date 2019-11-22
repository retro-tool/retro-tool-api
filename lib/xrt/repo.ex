defmodule Xrt.Repo do
  use Ecto.Repo,
    otp_app: :retro,
    adapter: Ecto.Adapters.Postgres
end
