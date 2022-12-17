defmodule Pretty.Compose do
  @moduledoc false

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_list` layed out in a 
  grid.

  ## Options

    * `:row_gap` - spaces between rows.
    * `:col_gap` - spaces between columns.
    * `:align_items` - (one of `:top`, `:middle`, `:bottom`) the vertical 
      alignment of the grid items.
    * `:justify_items` - (one of `:left`, `:center`, `:right`) the horizontal
      alignment of the grid items.
    * `:pad_items` - (a keyword list) the padding to add to each grid item.
    * `:pad_items_left` - spaces to pad the left side, overrides `:pad_items`.
    * `:pad_items_right` - spaces to pad the right side, overrides `:pad_items`.
    * `:pad_items_top` - spaces to pad the top, overrides `:pad_items`.
    * `:pad_items_bottom` - spaces to pad the bottom, overrides `:pad_items`.

  ## Examples

      iex> list = Pretty.From.list(["a", "b", "c"])
      iex> Pretty.Compose.grid(list, rows: 2, columns: 2) |> to_string
      "╭───┬───╮\n│ a │ b │\n├───┼───┤\n│ c │   │\n╰───┴───╯"
  """
  @spec grid([Pretty.Canvas.t()], Keyword.t()) :: Pretty.Canvas.t()
  def grid(canvas_list, options \\ []) do
    canvas_count = length(canvas_list)

    {rows, columns} = grid_dimensions(options, canvas_count)

    nth_row_column_counts = List.duplicate(columns, rows)

    options =
      options
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      &Pretty.Paint.grid_lines/2,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_list` layed out in a 
  grid without grid lines.

  see `grid/2` for options

  ## Examples

      iex> list = Pretty.From.list(["a", "b", "c"])
      iex> Pretty.Compose.grid_layout(list, rows: 2, columns: 2) |> to_string
      "a b\n   \nc  "
  """
  @spec grid_layout([Pretty.Canvas.t()], Keyword.t()) :: Pretty.Canvas.t()
  def grid_layout(canvas_list, options \\ []) do
    canvas_count = length(canvas_list)

    {rows, columns} = grid_dimensions(options, canvas_count)

    nth_row_column_counts = List.duplicate(columns, rows)

    options =
      options
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:pad_items, [top: 0, right: 0, bottom: 0, left: 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      nil,
      [top: 0, left: 0, right: 0, bottom: 0],
      options
    )
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_matrix` layed out in 
  a matrix-grid.

  ## Options

    See `grid/2`

  ## Examples

    iex> canvas_matrix = Pretty.From.matrix([["x"]]) 
    iex> Pretty.Compose.matrix(canvas_matrix) |> to_string
    "╭───╮\n│ x │\n╰───╯"
  """
  @spec matrix([[Pretty.Canvas.t()]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix(canvas_matrix, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])
      |> Keyword.put_new(:align_items, :top)

    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)
    canvas_list = List.flatten(canvas_matrix)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      &Pretty.Paint.grid_lines/2,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_matrix` layed out in 
  a matrix-grid without grid lines.

  ## Options

    See `grid/2`

  ## Examples

    iex> canvas_matrix = Pretty.From.matrix([["x", "y"], ["z", "w"]])
    iex> Pretty.Compose.matrix_layout(canvas_matrix) |> to_string
    "x y\n   \nz w"
  """
  @spec matrix_layout([[Pretty.Canvas.t()]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix_layout(canvas_matrix, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, [top: 0, right: 0, bottom: 0, left: 0])

    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)
    canvas_list = List.flatten(canvas_matrix)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      nil,
      [top: 0, left: 0, right: 0, bottom: 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a table.

  ## Options

    See `matrix/2`

  ## Example

      iex> headers = Pretty.From.list(["Name", "Age", "Height"])
      iex> rows = Pretty.From.matrix([
      ...>  ["Alice", "23", "169 cm"],
      ...>  ["Bob", "27", "181 cm"],
      ...>  ["Carol", "19", "200 cm"],
      ...> ])
      iex> Pretty.Compose.table(headers, rows) |> to_string
      "╭───────┬─────┬────────╮\n│ Name  │ Age │ Height │\n├───────┼─────┼────────┤\n│ Alice │ 23  │ 169 cm │\n│ Bob   │ 27  │ 181 cm │\n│ Carol │ 19  │ 200 cm │\n╰───────┴─────┴────────╯"
  """
  @spec table([Pretty.Canvas.t()], [[Pretty.Canvas.t()]], Keyword.t()) :: Pretty.Canvas.t()
  def table(headers, data, options \\ []) do
    canvas_matrix = [headers, [Pretty.From.term("@")] | data]

    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)

    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, options ->
      lines_header =
        Enum.filter(
          lines_map.horizontals,
          fn {{_, row}, _} -> row == 0 or row == 2 end
        )

      line_bottom = List.last(lines_map.horizontals)
      horizontals = [line_bottom | lines_header]

      intersects = lines_map.intersects

      intersects = %{
        intersects
        | left: Enum.filter(intersects.left, fn {_, row} -> row == 2 end),
          right: Enum.filter(intersects.right, fn {_, row} -> row == 2 end),
          cross: Enum.filter(intersects.cross, fn {_, row} -> row == 2 end)
      }

      lines_map = %{lines_map | horizontals: horizontals, intersects: intersects}
      Pretty.Paint.grid_lines(lines_map, options)
    end

    options =
      options
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:row_gap, 0)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      lines_renderer,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with the given `canvas` in a box.

  ## Options

    See `grid/2`

  ## Example

      iex> canvas = Pretty.From.term("x")
      iex> Pretty.Compose.box(canvas) |> to_string
      "╭───╮\n│ x │\n╰───╯"
  """
  @spec box(Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def box(canvas, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])

    Pretty.Compose.Grid.compose(
      [canvas],
      1,
      [1],
      &Pretty.Paint.grid_lines/2,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a card.

  ## Options

    See `grid/2`

  ## Example

      iex> label = Pretty.From.term("label")
      iex> message = Pretty.From.term("message")
      iex> Pretty.Compose.card(label, message) |> to_string
      "╭─────────╮\n│ label   │\n├─────────┤\n│ message │\n╰─────────╯"
  """
  @spec card(Pretty.Canvas.t(), Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def card(label, message, options \\ []) do
    table([label], [[message]], options)
  end

  @doc ~S"""
  Returns a canvas with a pretty map.

  ## Options

    See `matrix/2`

  ## Examples

      iex> canvas_map = %{Pretty.From.term(:color) => Pretty.From.term("red")}
      iex> Pretty.Compose.pretty_map(canvas_map) |> to_string
      "╭────────┬─────╮\n│ :color │ red │\n╰────────┴─────╯"
  """
  @spec pretty_map(%{Pretty.Canvas.t() => Pretty.Canvas.t()}, Keyword.t()) :: Pretty.Canvas.t()
  def pretty_map(canvas_map, options \\ []) do
    canvas_matrix = Enum.map(canvas_map, fn {key, value} -> [key, value] end)
    options = options |> Keyword.put_new(:align_items, :center)
    Pretty.Compose.matrix(canvas_matrix, options)
  end

  @doc ~S"""
  Returns a canvas with a plain map.

  ## Options

    See `matrix/2`

  ## Examples

      iex> canvas_map = %{Pretty.From.term(:color) => Pretty.From.term("red")}
      iex> Pretty.Compose.plain_map(canvas_map) |> to_string
      "%{:color => red}"
  """
  @spec plain_map(%{Pretty.Canvas.t() => Pretty.Canvas.t()}, Keyword.t()) :: Pretty.Canvas.t()
  def plain_map(canvas_map, options \\ []) do
    canvas_matrix = Enum.map(canvas_map, fn {key, value} -> [key, value] end)

    canvas_matrix =
      Enum.map(canvas_matrix, fn row ->
        Enum.intersperse(row, Pretty.From.term(" => "))
      end)

    canvas_matrix =
      Enum.intersperse(canvas_matrix, [Pretty.From.term(", ")])
      |> List.flatten()

    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, _options ->
      {x0, y0} = lines_map.corners.top_left
      {x1, y1} = lines_map.corners.bottom_right
      y_center = div(y0 + y1, 2)

      [
        Pretty.Paint.dot_at({x0 - 1, y_center}, "%"),
        Pretty.Paint.dot_at({x0, y_center}, "{"),
        Pretty.Paint.dot_at({x1, y_center}, "}")
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, [top: 0, right: 0, bottom: 0, left: 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [top: 0, left: 1, right: 1, bottom: 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty list.

  ## Options

    see `grid/2`

  ## Examples

      iex> canvas_list = Pretty.From.list([1, 2])
      iex> Pretty.Compose.pretty_list(canvas_list) |> to_string
      "╭      ╮\n│ 1  2 │\n╰      ╯"
  """
  @spec pretty_list([Pretty.Canvas.t()], Keyword.t()) :: Pretty.Canvas.t()
  def pretty_list(canvas_list, options \\ []) do
    lines_renderer = fn lines_map, options ->
      {p0, p1} = List.first(lines_map.verticals)
      {p2, p3} = List.last(lines_map.verticals)

      [
        Pretty.Paint.bracket_left(p0, p1, options),
        Pretty.Paint.bracket_right(p2, p3, options)
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a plain list.

  ## Options

    see `grid/2`

  ## Examples

      iex> canvas_list = Pretty.From.list([1, 2, 3])
      iex> Pretty.Compose.plain_list(canvas_list) |> to_string
      "[1, 2, 3]"
  """
  @spec plain_list([Pretty.Canvas.t()], Keyword.t()) :: Pretty.Canvas.t()
  def plain_list(canvas_list, options \\ []) do
    canvas_list =
      Enum.intersperse(canvas_list, [Pretty.From.term(", ")])
      |> List.flatten()

    lines_renderer = fn lines_map, _options ->
      {x0, y0} = lines_map.corners.top_left
      {x1, y1} = lines_map.corners.bottom_right
      y_center = div(y0 + y1, 2)

      [
        Pretty.Paint.dot_at({x0, y_center}, "["),
        Pretty.Paint.dot_at({x1, y_center}, "]")
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, [top: 0, right: 0, bottom: 0, left: 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [top: 0, left: 1, right: 1, bottom: 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty tuple.

  ## Options

    see `grid/2`

  ## Examples

      iex> canvas_tuple = Pretty.From.tuple{1, 2}
      iex> Pretty.Compose.pretty_tuple(canvas_tuple) |> to_string
      "╭      ╮\n┤ 1  2 ├\n╰      ╯"
  """
  @spec pretty_tuple(tuple(), Keyword.t()) :: Pretty.Canvas.t()
  def pretty_tuple(canvas_tuple, options \\ []) do
    canvas_list = Tuple.to_list(canvas_tuple)

    lines_renderer = fn lines_map, options ->
      {p0, p1} = List.first(lines_map.verticals)
      {p2, p3} = List.last(lines_map.verticals)

      [
        Pretty.Paint.curly_bracket_left(p0, p1, options),
        Pretty.Paint.curly_bracket_right(p2, p3, options)
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a plain tuple.

  ## Options

    see `grid/2`

  ## Examples

      iex> canvas_tuple = Pretty.From.tuple({1, 2, 3})
      iex> Pretty.Compose.plain_tuple(canvas_tuple) |> to_string
      "{1, 2, 3}"
  """
  @spec plain_tuple(tuple(), Keyword.t()) :: Pretty.Canvas.t()
  def plain_tuple(canvas_tuple, options \\ []) do
    canvas_list = Tuple.to_list(canvas_tuple)

    canvas_list =
      Enum.intersperse(canvas_list, [Pretty.From.term(", ")])
      |> List.flatten()

    lines_renderer = fn lines_map, _options ->
      {x0, y0} = lines_map.corners.top_left
      {x1, y1} = lines_map.corners.bottom_right
      y_center = div(y0 + y1, 2)

      [
        Pretty.Paint.dot_at({x0, y_center}, "{"),
        Pretty.Paint.dot_at({x1, y_center}, "}")
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, [top: 0, right: 0, bottom: 0, left: 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [top: 0, left: 1, right: 1, bottom: 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty math matrix given a `canvas_matrix`

  ## Options

    see `grid/2`

  ## Examples

      iex> canvas_matrix = Pretty.From.matrix([[1, 2], [3, 4]])
      iex> Pretty.Compose.math_matrix(canvas_matrix) |> to_string
      "╭       ╮\n│ 1   2 │\n│       │\n│ 3   4 │\n╰       ╯"
  """
  @spec math_matrix([Pretty.Canvas.t()], Keyword.t()) :: Pretty.Canvas.t()
  def math_matrix(canvas_matrix, options \\ []) do
    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)
    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, options ->
      {p0, p1} = List.first(lines_map.verticals)
      {p2, p3} = List.last(lines_map.verticals)

      [
        Pretty.Paint.bracket_left(p0, p1, options),
        Pretty.Paint.bracket_right(p2, p3, options)
      ]
      |> Pretty.Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 1)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [top: 0, right: 1, bottom: 0, left: 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :right)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      lines_renderer,
      [top: 1, left: 1, right: 1, bottom: 1],
      options
    )
  end

  # Calculate grid dimensions when a row or column counts is given
  defp grid_dimensions(options, canvas_count) do
    rows = Keyword.get(options, :rows, nil)
    columns = Keyword.get(options, :columns, nil)

    case [rows != nil, columns != nil] do
      [false, false] ->
        rows = 1
        columns = ceil(canvas_count / rows)
        {rows, columns}

      [true, false] ->
        columns = ceil(canvas_count / rows)
        {rows, columns}

      [false, true] ->
        rows = ceil(canvas_count / columns)
        {rows, columns}

      _ ->
        {rows, columns}
    end
  end
end
