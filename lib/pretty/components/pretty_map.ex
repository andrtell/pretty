defmodule Pretty.Components.PrettyMap do
  alias Pretty.Components.Matrix

  def paint(canvas_map, options \\ []) do
    matrix = Enum.map(canvas_map, fn {key, value} -> [key, value] end)

    options =
      Keyword.merge(
        [pad_items: [left: 1, right: 1], align_items: :center],
        options
      )

    Matrix.paint(matrix, options)
  end
end
