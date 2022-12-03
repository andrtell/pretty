defmodule Pretty.Components.PrettyTuple do
  alias Pretty.Canvas
  alias Pretty.Components.Bracket

  def paint(canvas_tuple, options \\ []) do
    canvas_list = Tuple.to_list(canvas_tuple)

    lines_renderer = fn lines_map, options ->
      {p0, p1} = List.first(lines_map.vertical_lines)
      {p2, p3} = List.last(lines_map.vertical_lines)

      [
        Bracket.paint(p0, p1, Keyword.merge(options, side: :left, curly: true)),
        Bracket.paint(p2, p3, Keyword.merge(options, side: :right, curly: true))
      ]
      |> Canvas.overlay()
    end

    options =
      Keyword.merge(
        [
          column_gap: 1,
          row_gap: 1,
          pad_items: [left: 0, right: 0, top: 0, bottom: 0],
          pad_grid: [left: 1, right: 1, top: 0, bottom: 0],
          align_items: :center,
          justify_items: :center,
          limit: 1,
          direction: :column
        ],
        options
      )

    Pretty.Grid.paint(
      canvas_list,
      lines_renderer,
      options
    )
  end
end
