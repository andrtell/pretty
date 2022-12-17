defmodule Pretty.Compose.Grid do
  @moduledoc false

  alias Pretty.Compose.Grid.Collect
  alias Pretty.Compose.Grid.Layout
  alias Pretty.Compose.Grid.DefaultOptions
  alias Pretty.Compose.Grid.LinesMap

  @doc ~S"""
  Returnes a new pretty canvas with the given canvases are layed out in a grid.

  ## Arguments

    * `canvas_list` - a list of canvases to layout
    * `row_count` - number of rows in the grid
    * `nth_row_column_count` - a list of column counts for each row.
       The reason this is a list is because this way it is possible to deal with ragged grids/matrices.
    * `lines_renderer_fun` - a function that takes a map of the grid lines, corners and intersect points, returns a canvas.
    * `lines_hint` - A keyword list that hints if grid lines will be drawn, and if so, adds a margin to the grid.
    * `options` - a keyword list of options. See `Pretty.Compose.Grid.DefaultOptions` for the default options.
  """
  @spec compose(
          [Canvas.t()],
          integer,
          [integer],
          (LinesMap.t(), Keyword.t() -> Canvas.t()),
          Keyword.t(),
          Keyword.t()
        ) :: Canvas.t()
  def compose(
        canvas_list,
        row_count,
        nth_row_column_count,
        lines_renderer_fun,
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
      if lines_renderer_fun do
        grid_lines = Collect.lines_map(layout)
        lines_renderer_fun.(grid_lines, options)
      else
        Pretty.Canvas.empty()
      end

    canvas_offsets = Collect.canvas_offsets(layout)

    grid_canvas =
      Enum.map(
        Enum.zip(canvas_list, canvas_offsets),
        fn {canvas, {dx, dy}} -> Pretty.Canvas.translate(canvas, dx, dy) end
      )
      |> Pretty.Canvas.overlay()

    Pretty.Canvas.overlay(grid_canvas, lines_canvas)
  end
end
