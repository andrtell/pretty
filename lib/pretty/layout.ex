defmodule Pretty.Layout do
  alias Pretty.Layout.Grid
  alias Pretty.Canvas

  @doc ~S"""
  Takes a list of `canvases` and lays them out in a grid.

  ## Arguments

    * `canvases` - a list of canvases to layout
    * `line_hints` - specifies padding for the grid lines. 
      A keyword list ([:left, :right, :top, :bottom]) with the number of spaces to add to 
      the respective side of the grid. Defaults to 0.
    * `lines_renderer` - a function that takes a map of the grid lines, corners and intersect points, returns a canvas.
    * `options` - a keyword list of options. See `Pretty.Layout.Grid.DefaultOptions` for the default options.
  """
  def grid(canvases, line_hints, lines_renderer, options \\ []) do
    canvases =
      Enum.with_index(canvases)
      |> Enum.map(fn {canvas, id} ->
        Pretty.Canvas.put_meta(canvas, :id, id)
      end)

    grid =
      Grid.new(line_hints, options)
      |> Grid.populate_items(canvases)
      |> Grid.place_items()
      |> Grid.add_null_items()
      |> Grid.calculate_column_dims()
      |> Grid.calculate_row_dims()
      |> Grid.set_item_dims()
      |> Grid.set_item_xy()

    canvases = Grid.position_canvases(grid, canvases, options)

    grid_canvas = Canvas.overlay(canvases)

    lines_canvas =
      if lines_renderer != nil do
        lines_map = Grid.make_grid_lines(grid, options)
        lines_renderer.(lines_map, options)
      else
        Pretty.Canvas.empty()
      end

    Pretty.Canvas.overlay(grid_canvas, lines_canvas)
  end
end
