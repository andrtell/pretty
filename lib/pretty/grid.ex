defmodule Pretty.Grid do
  alias Pretty.Canvas

  @doc ~S"""
  Returns a canvas with all the canvases in the given list `canvases` layed out
  in a grid.

  ## Arguments

    * `canvases` - A list of canvases to layout in a grid.
    * `lines_renderer` - A function that takes a map of the grid lines, corners
      and intersect points, returns a canvas.
    * `options` - A keyword list of options.

  ## Options

    * `:direction` - The direction in which to lay out the items of the grid. 
      Can be `:row` or `:column`. Defaults to `:row`.
    * `:limit` - The max number of cells in the direction direction. 

      :row         :column
    ╭───┬───╮     ╭───┬───╮ ┐
    │ 1 │ 2 │     │ 1 │ 3 │ │
    ├───┼───┤     ├───┼───┤ ┤ limit
    │ 3 │   │     │ 2 │   │ │
    ╰───┴───╯     ╰───┴───╯ ┘
    └───┴───┘
      limit

    * `:row_gap` - The gap between rows. Defaults to `0`.
    * `:column_gap` - The gap between columns. Defaults to `0`.
    * `:justify_items` - The justification of the items in the grid. Can be
      `:left`, `:center`, `:right`. Defaults to `:left`.
    * `:align_items` - The alignment of the items in the grid. Can be `:top`,
      `:center`, `:bottom`. Defaults to `:top`.
    * `:pad_items` - A keyword list that specifies the padding of the cells in 
      the grid. The keys are `:top`, `:bottom`, `:left` and `:right`. Defaults to `[]`.
    * `:pad_grid` - A keyword list that specifies the padding of the grid. The
      keys are `:top`, `:bottom`, `:left` and `:right`. Defaults to `[]`.
  """
  @spec paint([Canvas.t()], (Pretty.Grid.Lines.line_map() -> Canvas.t()), keyword()) :: Canvas.t()
  def paint(canvases, lines_renderer, options \\ []) do
    options = default_options(options)

    # give each canvas an id
    canvases =
      Enum.with_index(canvases)
      |> Enum.map(fn {canvas, id} ->
        Pretty.Canvas.put_meta(canvas, :__id, id)
      end)

    # make items from canvases
    items =
      Enum.map(canvases, fn canvas ->
        make_item(canvas, options)
      end)

    # place items in grid (row, column).
    {
      items,
      row_count,
      column_count
    } = Pretty.Grid.Placement.place_items(items, options[:direction], options[:limit], options)

    # adjust width and height of each item.
    {
      items,
      row_offsets,
      column_offsets,
      row_gap_offsets,
      column_gap_offsets
    } =
      Pretty.Grid.Sizing.size_items(
        items,
        row_count,
        column_count,
        options[:row_gap],
        options[:column_gap]
      )

    # paint grid lines?
    lines? = lines_renderer != nil

    {row_offsets, column_offsets, row_gap_offsets, column_gap_offsets} =
      if lines? do
        # adjust first and last gap offsets taking pad_grid into account.
        row_gap_offsets =
          Map.update!(row_gap_offsets, 0, fn {min, max} -> {min - options[:pad_grid_top], max} end)

        row_gap_offsets =
          Map.update!(row_gap_offsets, row_count - 1, fn {min, max} ->
            {min, max + options[:pad_grid_bottom]}
          end)

        column_gap_offsets =
          Map.update!(column_gap_offsets, 0, fn {min, max} ->
            {min - options[:pad_grid_left], max}
          end)

        column_gap_offsets =
          Map.update!(column_gap_offsets, column_count - 1, fn {min, max} ->
            {min, max + options[:pad_grid_right]}
          end)

        # translate offsets so that they are all positive
        {dy, _} = row_gap_offsets[0]
        {dx, _} = column_gap_offsets[0]

        {translate_offsets(row_offsets, -dy), translate_offsets(column_offsets, -dx),
         translate_offsets(row_gap_offsets, -dy), translate_offsets(column_gap_offsets, -dx)}
      else
        {row_offsets, column_offsets, row_gap_offsets, column_gap_offsets}
      end

    # position items
    items =
      Enum.map(items, fn item ->
        {x, _} = Map.get(column_offsets, item.column)
        {y, _} = Map.get(row_offsets, item.row)
        %{item | x: x, y: y}
      end)

    # paint grid lines (or not)
    lines_canvas =
      if lines? do
        line_map = Pretty.Grid.Lines.make_lines(items, row_gap_offsets, column_gap_offsets)
        lines_renderer.(line_map, options)
      else
        Canvas.empty()
      end

    # position canvases
    items_by_id =
      for item <- items,
          do: {item.id, item},
          into: %{}

    canvases =
      Enum.map(canvases, fn canvas ->
        position_canvas(
          items_by_id[Canvas.get_meta(canvas, :__id, nil)],
          canvas,
          options
        )
      end)
      |> Canvas.overlay()

    Canvas.overlay(canvases, lines_canvas)
  end

  @spec default_options(Keyword.t()) :: Keyword.t()
  defp default_options(options) do
    Keyword.merge(
      [
        direction: :row,
        limit: 1,
        row_gap: 1,
        column_gap: 1,
        pad_items_left: Keyword.get(options, :pad_items, []) |> Keyword.get(:left, 0),
        pad_items_right: Keyword.get(options, :pad_items, []) |> Keyword.get(:right, 0),
        pad_items_top: Keyword.get(options, :pad_items, []) |> Keyword.get(:top, 0),
        pad_items_bottom: Keyword.get(options, :pad_items, []) |> Keyword.get(:bottom, 0),
        pad_grid_left: Keyword.get(options, :pad_grid, []) |> Keyword.get(:left, 0),
        pad_grid_right: Keyword.get(options, :pad_grid, []) |> Keyword.get(:right, 0),
        pad_grid_top: Keyword.get(options, :pad_grid, []) |> Keyword.get(:top, 0),
        pad_grid_bottom: Keyword.get(options, :pad_grid, []) |> Keyword.get(:bottom, 0),
        justify_items: :left,
        align_items: :top
      ],
      options
    )
  end

  @spec make_item(Canvas.t(), Keyword.t()) :: Pretty.Grid.Item.t()
  defp make_item(canvas, options) do
    %Pretty.Grid.Item{
      id: Canvas.get_meta(canvas, :__id, nil),
      row_span: Canvas.get_meta(canvas, :row_span, 1),
      column_span: Canvas.get_meta(canvas, :column_span, 1),
      width: Canvas.width(canvas) + options[:pad_items_left] + options[:pad_items_right],
      height: Canvas.height(canvas) + options[:pad_items_top] + options[:pad_items_bottom],
      x: nil,
      y: nil
    }
  end

  def position_canvas(item, canvas, options) do
    dx = item.x
    dy = item.y

    justify_self = Canvas.get_meta(canvas, :justify_self, options[:justify_items])
    canvas_width = Canvas.width(canvas)

    dx =
      case justify_self do
        :right ->
          dx + item.width - canvas_width - options[:pad_items_right]

        :center ->
          dx + ceil((item.width - canvas_width) / 2)

        :left ->
          dx + options[:pad_items_left]
      end

    align_self = Canvas.get_meta(canvas, :align_self, options[:align_items])
    canvas_height = Canvas.height(canvas)

    dy =
      case align_self do
        :bottom ->
          dy + item.height - canvas_height - options[:pad_items_bottom]

        :center ->
          dy + floor((item.height - canvas_height) / 2)

        :top ->
          dy + options[:pad_items_top]
      end

    Canvas.translate(
      canvas,
      dx,
      dy
    )
  end

  defp translate_offsets(offsets, delta) do
    Enum.reduce(Map.keys(offsets), offsets, fn key, offsets ->
      Map.update!(offsets, key, fn {a, b} -> {a + delta, b + delta} end)
    end)
  end
end
