Postgrex.Types.define(
  Tasky.PostgrexTypes,
  [AshPostgres.Extensions.Vector] ++ Ecto.Adapters.Postgres.extensions(),
  []
)
