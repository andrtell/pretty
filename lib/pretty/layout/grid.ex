defmodule Pretty.Layout.Grid do
  alias Pretty.Layout.Grid.Item
  alias Pretty.Layout.Grid.DefaultOptions
  alias Pretty.Layout.Grid.LineMap

  alias Pretty.Canvas

  defstruct mode: :by_column,
            rows: 0,
            row_gap: 0,
            columns: 0,
            column_gap: 0,
            line_hints: [],
            pad_items_left: 0,
            pad_items_right: 0, 
            pad_items_top: 0,
            pad_items_bottom: 0,
            column_offsets: nil,
            column_widths: nil,
            row_heights: nil,
            row_offsets: nil,
            cells_with_item: nil,
            x_end_max: 0,
            y_end_max: 0,
            items: []

  def new(line_hints, options) do

    options = DefaultOptions.put(options)

    %__MODULE__{
      mode: options[:grid_mode],
      rows: options[:rows],
      columns: options[:columns],
      column_gap: options[:column_gap],
      row_gap: options[:row_gap],
      line_hints: line_hints,
      pad_items_left: options[:pad_items_left],
      pad_items_right: options[:pad_items_right],
      pad_items_top: options[:pad_items_top],
      pad_items_bottom: options[:pad_items_bottom],
      column_offsets: Map.new(),
      column_widths: Map.new(),
      row_heights: Map.new(),
      row_offsets: Map.new(),
      cells_with_item: MapSet.new(),
      items: []
    }
  end

  def populate_items(grid, canvases) do
    items = Enum.map(canvases, fn c -> Item.from_canvas(c, grid) end)
    %__MODULE__{grid | items: items}
  end

  def place_items(grid) do
    case grid.mode do
      :by_column ->
        place_items_by_column(grid)

      :by_row ->
        place_items_by_row(grid)
    end
  end

  def place_items_by_column(grid) do
    columns =
      max(
        grid.columns,
        grid.items |> Enum.map(& &1.column_span) |> Enum.max()
      )

    {placed, cells_with_item} = place_items_by_column(columns, grid.items, [], {0, 0}, MapSet.new())

    rows = placed |> Enum.map(& &1.row_end) |> Enum.max()

    %__MODULE__{
      grid
      | items: placed,
        cells_with_item: cells_with_item,
        columns: columns,
        rows: rows
    }
  end

  defp place_items_by_column(_columns, [], placed, _cursor, cells_with_item) do
    {placed, cells_with_item}
  end

  defp place_items_by_column(columns, [item | items], placed, current_cursor, cells_with_item) do
    next_cursor = next_free_column(columns, item, current_cursor, cells_with_item)
    {row, _} = next_cursor
    item = Item.place_item_at(item, next_cursor)
    item_area = MapSet.new(Item.area_at(item, next_cursor))

    place_items_by_column(
      columns,
      items,
      [item | placed],
      {row, item.column_end},
      MapSet.union(cells_with_item, item_area)
    )
  end


  defp next_free_column(columns, item, {row, column} = current_cursor, cells_with_item) do
    if Item.fits_row?(item, current_cursor, columns) do
      if Item.overlaps_at?(item, current_cursor, cells_with_item) do
        next_free_column(columns, item, {row, column + 1}, cells_with_item)
      else
        {row, column}
      end
    else
      next_free_column(columns, item, {row + 1, 0}, cells_with_item)
    end
  end

  def place_items_by_row(grid) do
    rows =
      max(
        grid.rows,
        grid.items |> Enum.map(& &1.row_span) |> Enum.max()
      )

    {placed, cells_with_item} = place_items_by_row(rows, grid.items, [], {0, 0}, MapSet.new())

    columns = placed |> Enum.map(& &1.column_end) |> Enum.max()

    %__MODULE__{
      grid
      | items: placed,
        cells_with_item: cells_with_item,
        rows: rows,
        columns: columns
    }
  end

  defp place_items_by_row(_rows, [], placed, _cursor, cells_with_item) do
    {placed, cells_with_item}
  end

  defp place_items_by_row(rows, [item | items], placed, current_cursor, cells_with_item) do
    next_cursor = next_free_row(rows, item, current_cursor, cells_with_item)
    {_, column} = next_cursor
    item = Item.place_item_at(item, next_cursor)
    item_area = MapSet.new(Item.area_at(item, next_cursor))

    place_items_by_row(
      rows,
      items,
      [item | placed],
      {item.row_end, column},
      MapSet.union(cells_with_item, item_area)
    )
  end

  defp next_free_row(rows, item, {row, column} = current_cursor, cells_with_item) do
    if Item.fits_column?(item, current_cursor, rows) do
      if Item.overlaps_at?(item, current_cursor, cells_with_item) do
        next_free_row(rows, item, {row + 1, column}, cells_with_item)
      else
        {row, column}
      end
    else
      next_free_row(rows, item, {0, column + 1}, cells_with_item)
    end
  end

  def add_null_items(grid) do
    empty_items =
      for row <- 0..(grid.rows - 1),
          column <- 0..(grid.columns - 1),
          not MapSet.member?(grid.cells_with_item, {row, column}) do
        %Item{
          row_start: row,
          row_end: row + 1,
          column_start: column,
          column_end: column + 1,
          column_span: 1,
          row_span: 1,
          height: 1,
          width: 1
        }
      end

    %__MODULE__{grid | items: empty_items ++ grid.items}
  end

  def calculate_column_dims(grid) do
    # default column width is 1
    column_widths = for c <- 0..(grid.columns - 1), do: {c, 1}, into: %{}

    # start with items that only span 1 column
    column_widths =
      grid.items
      |> Enum.filter(&(&1.column_span == 1))
      |> Enum.reduce(column_widths, fn item, widths ->
        Map.update(widths, item.column_start, item.width, &max(&1, item.width))
      end)

    # then do items that spans many columns
    column_widths =
      grid.items
      |> Enum.filter(&(&1.column_span > 1))
      |> Enum.reduce(column_widths, fn item, column_widths ->
        span_width =
          calculate_column_span_width(
            item.column_start,
            item.column_end,
            column_widths,
            grid.column_gap
          )

        width_diff = item.width - span_width

        cond do
          width_diff > 0 ->
            Enum.reduce(0..(width_diff - 1), column_widths, fn i, widths ->
              Map.update(widths, item.column_start + rem(i, item.column_span), 1, &(&1 + 1))
            end)

          true ->
            column_widths
        end
      end)

    column_offset = offsets(column_widths, grid.column_gap)

    %__MODULE__{grid | column_widths: column_widths, column_offsets: column_offset}
  end

  defp calculate_column_span_width(column_start, column_end, column_widths, column_gap) do
    width =
      Enum.map(
        column_start..(column_end - 1),
        &Map.get(column_widths, &1)
      )
      |> Enum.sum()

    width + (column_end - column_start - 1) * column_gap
  end

  def calculate_row_dims(grid) do
    # default row height is 1
    row_heights = for r <- 0..(grid.rows - 1), do: {r, 1}, into: %{}

    # start with items that only span 1 row
    row_heights =
      grid.items
      |> Enum.filter(fn item -> item.row_span == 1 end)
      |> Enum.reduce(row_heights, fn item, row_heights ->
        Map.update(row_heights, item.row_start, item.height, &max(&1, item.height))
      end)

    # then do items that spans many rows
    row_heights =
      grid.items
      |> Enum.filter(fn item -> item.row_span > 1 end)
      |> Enum.reduce(row_heights, fn item, row_heights ->
        span_height =
          calculate_row_span_height(item.row_start, item.row_end, row_heights, grid.row_gap)

        height_diff = item.height - span_height

        if height_diff > 0,
          do:
            Enum.reduce(0..(height_diff - 1), row_heights, fn i, m ->
              Map.update(m, item.row_start + rem(i, item.row_span), 1, &(&1 + 1))
            end),
          else: row_heights
      end)

    row_offsets = offsets(row_heights, grid.row_gap)

    %__MODULE__{grid | row_heights: row_heights, row_offsets: row_offsets}
  end

  defp calculate_row_span_height(row_start, row_end, row_heights, row_gap) do
    height =
      Enum.map(
        row_start..(row_end - 1),
        &Map.get(row_heights, &1)
      )
      |> Enum.sum()

    height + (row_end - row_start - 1) * row_gap
  end

  defp offsets(dims, gap) do
    Map.to_list(dims)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> List.insert_at(0, 0)
    |> Enum.scan(-gap, &(&1 + &2 + gap))
    |> Enum.with_index(fn x, i -> {i, x} end)
    |> Map.new()
  end

  def set_item_dims(grid) do
    items =
      Enum.map(grid.items, fn item ->
        width =
          calculate_column_span_width(
            item.column_start,
            item.column_end,
            grid.column_widths,
            grid.column_gap
          )

        height =
          calculate_row_span_height(item.row_start, item.row_end, grid.row_heights, grid.row_gap)

        %Item{
          item
          | width: width,
            height: height
        }
      end)

    %__MODULE__{grid | items: items}
  end

  def set_item_xy(grid) do
    hint_left = Keyword.get(grid.line_hints, :left, 0)
    hint_top = Keyword.get(grid.line_hints, :top, 0)

    {items, {x_end_max, y_end_max}} =
      Enum.map_reduce(grid.items, {0, 0}, fn item, {x_end_max, y_end_max} ->
        x_start = Map.get(grid.column_offsets, item.column_start) + hint_left
        x_end = Map.get(grid.column_offsets, item.column_end) - grid.column_gap + hint_left
        y_start = Map.get(grid.row_offsets, item.row_start) + hint_top
        y_end = Map.get(grid.row_offsets, item.row_end) - grid.row_gap + hint_top

        item = %Item{
          item
          | x_start: x_start,
            x_end: x_end,
            y_start: y_start,
            y_end: y_end
        }

        x_end_max = max(x_end, x_end_max)
        y_end_max = max(y_end, y_end_max)

        {item, {x_end_max, y_end_max}}
      end)

    {items, x_end_max, y_end_max}

    %__MODULE__{
      grid
      | items: items,
        x_end_max: x_end_max,
        y_end_max: y_end_max
    }
  end

  def position_canvases(grid, canvases, options) do
    items_by_id =
      for item <- grid.items,
          do: {item.id, item},
          into: %{}

    Enum.map(canvases, fn canvas ->
      translate_canvas(
        grid,
        items_by_id[Canvas.get_meta(canvas, :id, 0)],
        canvas,
        options
      )
    end)
  end

  def translate_canvas(grid, item, canvas, options) do
    dx = item.x_start
    dy = item.y_start

    justify_items = Keyword.get(options, :justify_items, :left)
    justify_self = Canvas.get_meta(canvas, :justify_self, justify_items)

    canvas_width = Canvas.box(canvas) |> Pretty.Canvas.Box.width()

    dx =
      case justify_self do
        :right ->
          dx + item.width - canvas_width - grid.pad_items_right

        :center ->
          dx + ceil((item.width - canvas_width) / 2)

        :left ->
          dx + grid.pad_items_left
      end

    align_items = Keyword.get(options, :align_items, :top)
    align_self = Canvas.get_meta(canvas, :align_self, align_items)

    canvas_height = Canvas.box(canvas) |> Pretty.Canvas.Box.height()

    dy =
      case align_self do
        :bottom ->
          dy + item.height - canvas_height - grid.pad_items_bottom

        :center ->
          dy + floor((item.height - canvas_height) / 2)

        :top ->
          dy + grid.pad_items_top
      end

    Canvas.translate(
      canvas,
      dx,
      dy
    )
  end

  def make_grid_lines(grid, _options \\ []) do
    hint_left = Keyword.get(grid.line_hints, :left, 0)
    hint_top = Keyword.get(grid.line_hints, :top, 0)
    hint_right = Keyword.get(grid.line_hints, :right, 0)
    hint_bottom = Keyword.get(grid.line_hints, :bottom, 0)

    row_gap_top = div(grid.row_gap, 2)
    row_gap_bot = grid.row_gap - row_gap_top

    col_gap_left = div(grid.column_gap, 2)
    col_gap_right = grid.column_gap - col_gap_left

    {grid_lines_horizontal, grid_lines_vertical, grid_intersects} =
      Enum.reduce(grid.items, {[], [], %{}}, fn item, {hs, vs, is} ->
        at_left_edge? = item.x_start == hint_left

        x_start =
          if at_left_edge?,
            do: item.x_start - hint_left,
            else: item.x_start - col_gap_left - 1

        at_right_edge? = item.x_end == grid.x_end_max

        x_end =
          if at_right_edge?,
            do: item.x_end + hint_right - 1,
            else: item.x_end + col_gap_right - 1

        at_top_edge? = item.y_start == hint_top

        y_start =
          if at_top_edge?,
            do: item.y_start - hint_top,
            else: item.y_start - row_gap_top - 1

        at_bottom_edge? = item.y_end == grid.y_end_max

        y_end =
          if at_bottom_edge?,
            do: item.y_end + hint_bottom - 1,
            else: item.y_end + row_gap_bot - 1

        hs =
          [
            {{x_start, y_start}, {x_end, y_start}},
            {{x_start, y_end}, {x_end, y_end}}
          ] ++ hs

        vs =
          [
            {{x_start, y_start}, {x_start, y_end}},
            {{x_end, y_start}, {x_end, y_end}}
          ] ++ vs

        is =
          Map.update(is, {x_start, y_start}, %{right: true, down: true}, fn m ->
            m |> Map.put(:right, true) |> Map.put(:down, true)
          end)

        is =
          if at_left_edge?,
            do: is |> Map.update!({x_start, y_start}, &Map.put(&1, :up, true)),
            else: is

        is =
          if at_top_edge?,
            do: is |> Map.update!({x_start, y_start}, &Map.put(&1, :left, true)),
            else: is

        is =
          Map.update(is, {x_start, y_end}, %{right: true, up: true}, fn m ->
            m |> Map.put(:right, true) |> Map.put(:up, true)
          end)

        is =
          if at_left_edge?,
            do: is |> Map.update!({x_start, y_end}, &Map.put(&1, :down, true)),
            else: is

        is =
          if at_bottom_edge?,
            do: is |> Map.update!({x_start, y_end}, &Map.put(&1, :left, true)),
            else: is

        is =
          Map.update(is, {x_end, y_start}, %{left: true, down: true}, fn m ->
            m |> Map.put(:left, true) |> Map.put(:down, true)
          end)

        is =
          if at_right_edge?,
            do: is |> Map.update!({x_end, y_start}, &Map.put(&1, :up, true)),
            else: is

        is =
          if at_top_edge?,
            do: is |> Map.update!({x_end, y_start}, &Map.put(&1, :right, true)),
            else: is

        is =
          Map.update(is, {x_end, y_end}, %{left: true, up: true}, fn m ->
            m |> Map.put(:left, true) |> Map.put(:up, true)
          end)

        is =
          if at_right_edge?,
            do: is |> Map.update!({x_end, y_end}, &Map.put(&1, :down, true)),
            else: is

        is =
          if at_bottom_edge?,
            do: is |> Map.update!({x_end, y_end}, &Map.put(&1, :right, true)),
            else: is

        # for items that span more than one column

        is =
          if item.column_span > 1 do
            Enum.reduce((item.column_start + 1)..(item.column_end - 1), is, fn col, is ->
              x_inter = Map.get(grid.column_offsets, col, 0) - col_gap_right + hint_left

              is
              |> Map.update({x_inter, y_start}, %{left: true}, &Map.put(&1, :left, true))
              |> Map.update({x_inter, y_start}, %{right: true}, &Map.put(&1, :right, true))
              |> Map.update({x_inter, y_end}, %{left: true}, &Map.put(&1, :left, true))
              |> Map.update({x_inter, y_end}, %{right: true}, &Map.put(&1, :right, true))
            end)
          else
            is
          end

        # for items that span more than one row

        is =
          if item.row_span > 1 do
            Enum.reduce((item.row_start + 1)..(item.row_end - 1), is, fn row, is ->
              y_inter = Map.get(grid.row_offsets, row, 0) - row_gap_bot + hint_top

              is
              |> Map.update({x_start, y_inter}, %{up: true}, &Map.put(&1, :up, true))
              |> Map.update({x_start, y_inter}, %{down: true}, &Map.put(&1, :down, true))
              |> Map.update({x_end, y_inter}, %{up: true}, &Map.put(&1, :up, true))
              |> Map.update({x_end, y_inter}, %{down: true}, &Map.put(&1, :down, true))
            end)
          else
            is
          end

        {hs, vs, is}
      end)

    # Overlay grid lines at the edges
    grid_lines_horizontal =
      [
        {{0, 0}, {grid.x_end_max, 0}},
        {{0, grid.y_end_max}, {grid.x_end_max, grid.y_end_max}}
      ] ++ grid_lines_horizontal

    grid_lines_vertical =
      [
        {{0, 0}, {0, grid.y_end_max}},
        {{grid.x_end_max, 0}, {grid.x_end_max, grid.y_end_max}}
      ] ++ grid_lines_vertical

    # Overlay corners
    grid_corners =
      %{}
      |> Map.put({0, 0}, %{right: true, down: true})
      |> Map.put({0, grid.y_end_max}, %{right: true, up: true})
      |> Map.put({grid.x_end_max, 0}, %{left: true, down: true})
      |> Map.put({grid.x_end_max, grid.y_end_max}, %{left: true, up: true})

    grid_intersects = Map.merge(grid_intersects, grid_corners)

    grid_intersects = pretty_intersects(grid_intersects)
    grid_corners = pretty_intersects(grid_corners)

    %LineMap{
      horizontals: grid_lines_horizontal,
      verticals: grid_lines_vertical,
      intersects: grid_intersects,
      corners: grid_corners
    }

  end

  def pretty_intersects(intersects) do
    Enum.map(Map.to_list(intersects), fn {k, v} ->
        v = case v do
          %{right: true, left: true, up: true, down: true} ->
            :vertical_and_horizontal

          %{right: true, left: true, up: true} ->
            :up_and_horizontal

          %{right: true, left: true, down: true} ->
            :down_and_horizontal

          %{right: true, up: true, down: true} ->
            :vertical_and_right

          %{left: true, up: true, down: true} ->
            :vertical_and_left

          %{down: true, right: true} ->
            :down_and_right

          %{down: true, left: true} ->
            :down_and_left

          %{up: true, right: true} ->
            :up_and_right

          %{up: true, left: true} ->
            :up_and_left

          _ ->
            :none
        end
      {k, v}
    end) |> Enum.filter(fn {_, v} -> v != :none end) |> Enum.into(%{})
  end

end
