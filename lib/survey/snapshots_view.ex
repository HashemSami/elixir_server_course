defmodule Survey.SnapshotsView do
  require EEx

  @templates_path Path.expand("../../templates", __DIR__)

  EEx.function_from_file(:def, :index, Path.join(@templates_path, "snapshots.html.eex"), [
    :snapshots
  ])
end
