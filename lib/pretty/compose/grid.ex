defmodule Pretty.Compose.Grid do
  alias Pretty.Compose.Grid.Collect
  alias Pretty.Compose.Grid.Layout
  alias Pretty.Compose.Grid.DefaultOptions

  def compose(
        canvas_list,
        row_count,
        nth_row_column_count,
        lines_renderer,
        lines_hints,
        options
      ) do
    layout =
      Layout.create(
        canvas_list,
        row_count,
        nth_row_column_count,
        lines_hints,
        options |> DefaultOptions.put()
      )

    lines_canvas =
      if lines_renderer do
        grid_lines = Collect.lines_map(layout)
        lines_renderer.(grid_lines, options)
      else
        Pretty.Canvas.empty()
      end

    canvas_offsets = Collect.canvas_offsets(layout)

    grid_canvas =
      Enum.map(
        Enum.zip(canvas_list, canvas_offsets),
        fn {canvas, {dx, dy}} -> Pretty.Canvas.translate(canvas, dx, dy) end
      )
      |> Pretty.Canvas.overlay_all()

    Pretty.Canvas.overlay(grid_canvas, lines_canvas)
  end
end
