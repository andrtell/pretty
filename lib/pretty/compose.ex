defmodule Pretty.Compose do
  alias Pretty.Canvas
  alias Pretty.Paint

  @moduledoc false

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_list` layed out in a 
  grid.

  ## Options

    * `:rows` - The number of rows in the grid. Defaults to 1.
    * `:columns` - The number of columns in the grid. Defaults to 1.
        If both `:rows` and `:columns` are specified, `:columns` takes precedence.
    * `:row_gap` - spaces between rows.
    * `:column_gap` - spaces between columns.
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
      iex> Pretty.Compose.grid(list, columns: 2) |> to_string
      "╭───┬───╮\n│ a │ b │\n├───┼───┤\n│ c │   │\n╰───┴───╯"
  """
  @spec grid([Canvas.t()], Keyword.t()) :: Canvas.t()
  def grid(canvas_list, options \\ []) do
    options =
      options
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:row_gap, 1)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      &Paint.grid_lines/2,
      options
    )
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `canvas_list` layed out in a 
  grid without grid lines.

  see `grid/2` for options

  ## Examples

      iex> list = Pretty.From.list(["a", "b", "c"])
      iex> Pretty.Compose.grid_layout(list, columns: 2, row_gap: 0) |> to_string
      "a b\nc  "
  """
  @spec grid_layout([Canvas.t()], Keyword.t()) :: Canvas.t()
  def grid_layout(canvas_list, options \\ []) do
    options =
      options
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:pad_items, top: 0, right: 0, bottom: 0, left: 0)

    Pretty.Layout.grid(
      canvas_list,
      [top: 0, left: 0, right: 0, bottom: 0],
      nil,
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
  @spec matrix([[Canvas.t()]], Keyword.t()) :: Canvas.t()
  def matrix(canvas_matrix, options \\ []) do
    columns = canvas_matrix |> Enum.map(&length/1) |> Enum.max() || 0

    canvas_matrix =
      canvas_matrix
      |> Enum.map(fn row ->
        row ++ List.duplicate(Canvas.empty(), columns - length(row))
      end)

    options =
      options
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:columns, columns)

    canvas_list = List.flatten(canvas_matrix)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      &Paint.grid_lines/2,
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
  @spec matrix_layout([[Canvas.t()]], Keyword.t()) :: Canvas.t()
  def matrix_layout(canvas_matrix, options \\ []) do
    columns = canvas_matrix |> Enum.map(&length/1) |> Enum.max() || 0

    canvas_matrix =
      canvas_matrix
      |> Enum.map(fn row ->
        row ++ List.duplicate(Canvas.empty(), columns - length(row))
      end)

    options =
      options
      |> Keyword.put_new(:pad_items, top: 0, right: 0, bottom: 0, left: 0)
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:columns, columns)

    canvas_list = List.flatten(canvas_matrix)

    Pretty.Layout.grid(
      canvas_list,
      [top: 0, left: 0, right: 0, bottom: 0],
      nil,
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
  @spec table([Canvas.t()], [[Canvas.t()]], Keyword.t()) :: Canvas.t()
  def table(headers, data, options \\ []) do
    columns = length(headers)

    canvas_matrix = [headers, List.duplicate(Pretty.From.term("@"), columns) | data]

    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, options ->
      {_, last} = lines_map.intersects |> Map.keys() |> Enum.max_by(fn {_, row} -> row end)

      horizontals =
        lines_map.horizontals
        |> Enum.filter(fn {{_, row}, {_, _}} -> Enum.member?([0, 2, last], row) end)

      intersects =
        lines_map.intersects
        |> Map.to_list()
        |> Enum.filter(fn {{_, row}, _} -> Enum.member?([0, 2, last], row) end)
        |> Enum.into(%{})

      lines_map = %{lines_map | horizontals: horizontals, intersects: intersects}

      Paint.grid_lines(lines_map, options)
    end

    options =
      options
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:align_items, :top)
      |> Keyword.put_new(:row_gap, 0)
      |> Keyword.put_new(:columns, columns)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      lines_renderer,
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
  @spec box(Canvas.t(), Keyword.t()) :: Canvas.t()
  def box(canvas, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)

    Pretty.Layout.grid(
      [canvas],
      [top: 1, left: 1, right: 1, bottom: 1],
      &Paint.grid_lines/2,
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
  @spec card(Canvas.t(), Canvas.t(), Keyword.t()) :: Canvas.t()
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
  @spec pretty_map(%{Canvas.t() => Canvas.t()}, Keyword.t()) :: Canvas.t()
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
  @spec plain_map(%{Canvas.t() => Canvas.t()}, Keyword.t()) :: Canvas.t()
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
      {x0, y0} = lines_map.corners |> Map.keys() |> Enum.min_by(fn {x, y} -> {x, y} end)
      {x1, y1} = lines_map.corners |> Map.keys() |> Enum.max_by(fn {x, y} -> {x, y} end)
      y_center = div(y0 + y1, 2)

      [
        Paint.dot_at({x0 - 1, y_center}, "%"),
        Paint.dot_at({x0, y_center}, "{"),
        Paint.dot_at({x1, y_center}, "}")
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, top: 0, right: 0, bottom: 0, left: 0)
      |> Keyword.put_new(:rows, 1)

    Pretty.Layout.grid(
      canvas_list,
      [top: 0, left: 1, right: 1, bottom: 0],
      lines_renderer,
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
  @spec pretty_list([Canvas.t()], Keyword.t()) :: Canvas.t()
  def pretty_list(canvas_list, options \\ []) do
    lines_renderer = fn lines_map, options ->
      {p0, p1} = List.first(lines_map.verticals)
      {p2, p3} = List.last(lines_map.verticals)

      [
        Paint.bracket_left(p0, p1, options),
        Paint.bracket_right(p2, p3, options)
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)
      |> Keyword.put_new(:rows, 1)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      lines_renderer,
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
  @spec plain_list([Canvas.t()], Keyword.t()) :: Canvas.t()
  def plain_list(canvas_list, options \\ []) do
    canvas_list =
      Enum.intersperse(canvas_list, [Pretty.From.term(", ")])
      |> List.flatten()

    lines_renderer = fn lines_map, _options ->
      {x0, y0} = lines_map.corners |> Map.keys() |> Enum.min_by(fn {x, y} -> {x, y} end)
      {x1, y1} = lines_map.corners |> Map.keys() |> Enum.max_by(fn {x, y} -> {x, y} end)
      y_center = div(y0 + y1, 2)

      [
        Paint.dot_at({x0, y_center}, "["),
        Paint.dot_at({x1, y_center}, "]")
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, top: 0, right: 0, bottom: 0, left: 0)
      |> Keyword.put_new(:rows, 1)
      |> Keyword.put_new(:align_items, :bottom)

    Pretty.Layout.grid(
      canvas_list,
      [top: 0, left: 1, right: 1, bottom: 0],
      lines_renderer,
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
  @spec pretty_tuple(tuple(), Keyword.t()) :: Canvas.t()
  def pretty_tuple(canvas_tuple, options \\ []) do
    canvas_list = Tuple.to_list(canvas_tuple)

    lines_renderer = fn lines_map, options ->
      {p0, p1} = lines_map.verticals |> Enum.min_by(fn {{x, _}, _p1} -> x end)
      {p2, p3} = lines_map.verticals |> Enum.max_by(fn {{x, _}, _p1} -> x end)

      [
        Paint.curly_bracket_left(p0, p1, options),
        Paint.curly_bracket_right(p2, p3, options)
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)
      |> Keyword.put_new(:rows, 1)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      lines_renderer,
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
  @spec plain_tuple(tuple(), Keyword.t()) :: Canvas.t()
  def plain_tuple(canvas_tuple, options \\ []) do
    canvas_list = Tuple.to_list(canvas_tuple)

    canvas_list =
      Enum.intersperse(canvas_list, [Pretty.From.term(", ")])
      |> List.flatten()

    lines_renderer = fn lines_map, _options ->
      {x0, y0} = lines_map.corners |> Map.keys() |> Enum.min_by(fn {x, y} -> {x, y} end)
      {x1, y1} = lines_map.corners |> Map.keys() |> Enum.max_by(fn {x, y} -> {x, y} end)
      y_center = div(y0 + y1, 2)

      [
        Paint.dot_at({x0, y_center}, "{"),
        Paint.dot_at({x1, y_center}, "}")
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, top: 0, right: 0, bottom: 0, left: 0)
      |> Keyword.put_new(:rows, 1)

    Pretty.Layout.grid(
      canvas_list,
      [top: 0, left: 1, right: 1, bottom: 0],
      lines_renderer,
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
  @spec math_matrix([Canvas.t()], Keyword.t()) :: Canvas.t()
  def math_matrix(canvas_matrix, options \\ []) do
    columns = canvas_matrix |> List.first() |> length()

    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, options ->
      {p0, p1} = lines_map.verticals |> Enum.min_by(fn {{x, _}, _p1} -> x end)
      {p2, p3} = lines_map.verticals |> Enum.max_by(fn {{x, _}, _p1} -> x end)

      [
        Paint.bracket_left(p0, p1, options),
        Paint.bracket_right(p2, p3, options)
      ]
      |> Canvas.overlay()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 1)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, top: 0, right: 1, bottom: 0, left: 1)
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :right)
      |> Keyword.put_new(:columns, columns)

    Pretty.Layout.grid(
      canvas_list,
      [top: 1, left: 1, right: 1, bottom: 1],
      lines_renderer,
      options
    )
  end
end
