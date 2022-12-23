defmodule Pretty.Components.MatrixLayout do
  alias Pretty.Canvas
  alias Pretty.Components.GridLayout

  def paint(matrix, options \\ []) do
    columns = matrix |> Enum.map(&length/1) |> Enum.max() || 0

    matrix =
      matrix
      |> Enum.map(fn row ->
        row ++ List.duplicate(Canvas.empty(), columns - length(row))
      end)

    options =
      Keyword.merge(
        [
          limit: columns,
          pad_items: [left: 1, right: 1, top: 1, bottom: 1]
        ],
        options
      )

    GridLayout.paint(List.flatten(matrix), options)
  end
end
