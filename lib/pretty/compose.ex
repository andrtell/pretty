defmodule Pretty.Compose do
  @moduledoc """
  A module for generating grid-like canvases from a list of canvases.
  """

  @doc ~S"""
  Returns a canvas with a grid given a `canvas_list`.

  The `canvas_list` must be a list of Pretty.Canvas.

  ## Options

    * `:row_gap` - (positive integer) the number of spaces between rows.
    * `:col_gap` - (positive integer) the number of spaces between columns.
    * `:align_items` - (one of `:top`, `:middle`, `:bottom`) the vertical 
      alignment of the grid items.
    * `:justify_items` - (one of `:left`, `:center`, `:right`) the horizontal
      alignment of the grid items.
    * `:pad_grid_left` - (positive integer) the number of spaces to pad the left side.
    * `:pad_grid_right` - (positive integer) the number of spaces to pad the right side.
    * `:pad_grid_top` - (positive integer) the number of spaces to pad the top side.
    * `:pad_grid_bottom` - (positive integer) the number of spaces to pad the bottom side.

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
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      &Pretty.Paint.grid_lines/2,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with two canvases side by side given `left` and `right`.

  The `left` must be a Pretty.Canvas.
  The `right` must be a Pretty.Canvas.

  See `grid/2` for more information.

  ## Examples
      
      iex> Pretty.Compose.join(Pretty.From.term("hello"), Pretty.From.term("world")) |> to_string
      "hello world"
  """
  @spec join(Pretty.Canvas.t(), Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def join(left, right, options \\ []) do
    Pretty.Compose.Grid.compose(
      [left, right],
      1,
      [2],
      nil,
      [0, 0, 0, 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with one canvas above another given `top` and `bottom`.

  The `top` must be a Pretty.Canvas.
  The `bottom` must be a Pretty.Canvas.

  See `grid/2` for more information.

  ## Examples
      
      iex> Pretty.Compose.stack(Pretty.From.term("hello"), Pretty.From.term("world"), row_gap: 0) |> to_string
      "hello\nworld"
  """
  @spec stack(Pretty.Canvas.t(), Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def stack(top, bottom, options \\ []) do
    Pretty.Compose.Grid.compose(
      [top, bottom],
      2,
      [1, 1],
      nil,
      [0, 0, 0, 0],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a grid given a `canvas_matrix`.

  The `canvas_matrix` must be a list of lists of Pretty.Canvas.

  The options `:rows` and `:columns` are given by the matrix dimensions
  and can not be overridden.

  Ragged matrices are ok.

  ## Options

    see `grid/2`

  ## Examples

    iex> canvas_matrix = Pretty.From.matrix([["x"]]) 
    iex> Pretty.Compose.matrix(canvas_matrix) |> to_string
    "╭───╮\n│ x │\n╰───╯"
  """
  @spec matrix([[Pretty.Canvas.t()]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix(canvas_matrix, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])
      |> Keyword.put_new(:align_items, :top)

    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)
    canvas_list = List.flatten(canvas_matrix)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      &Pretty.Paint.grid_lines/2,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a table given `headers` and `rows`.

  The `headers` must be a list of Pretty.Canvas.

  The `rows` must be a list of lists of Pretty.Canvas.

  ## Example

      iex> headers = Pretty.From.list(["Name", "Age", "Height"])
      iex> rows = Pretty.From.matrix([
      ...>  ["Alice", "23", "169 cm"],
      ...>  ["Bob", "27", "181 cm"],
      ...>  ["Carol", "19", "200 cm"],
      ...> ])
      iex> Pretty.Compose.table(headers, rows) |> to_string
      "╭───────┬─────┬────────╮\n│ Name  │ Age │ Height │\n├───────┼─────┼────────┤\n│ Alice │ 23  │ 169 cm │\n├       ┼     ┼        ┤\n│ Bob   │ 27  │ 181 cm │\n├       ┼     ┼        ┤\n│ Carol │ 19  │ 200 cm │\n╰───────┴─────┴────────╯"

  ## Options

    see `matrix/2`
  """
  @spec table([Pretty.Canvas.t()], [[Pretty.Canvas.t()]], Keyword.t()) :: Pretty.Canvas.t()
  def table(headers, data, options \\ []) do
    canvas_matrix = [headers | data]

    rows = length(canvas_matrix)
    nth_row_column_counts = Enum.map(canvas_matrix, &length/1)

    canvas_list = List.flatten(canvas_matrix)

    lines_renderer = fn lines_map, options ->
      lines_header = Enum.take(lines_map.horizontals, 2)
      line_bottom = List.last(lines_map.horizontals)
      horizontals = [line_bottom | lines_header]
      lines_map = %{lines_map | horizontals: horizontals}
      Pretty.Paint.grid_lines(lines_map, options)
    end

    options =
      options
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])
      |> Keyword.put_new(:align_items, :top)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      lines_renderer,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with the given `canvas` in a box.

  ## Example

      iex> canvas = Pretty.From.term("x")
      iex> Pretty.Compose.box(canvas) |> to_string
      "╭───╮\n│ x │\n╰───╯"

  ## Options

    see `grid/2`
  """
  @spec box(Pretty.Canvas.t()) :: Pretty.Canvas.t()
  def box(canvas, options \\ []) do
    options =
      options
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])

    Pretty.Compose.Grid.compose(
      [canvas],
      1,
      [1],
      &Pretty.Paint.grid_lines/2,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with the given a `label` and a `message` in a card.

  ## Example

      iex> label = Pretty.From.term("label")
      iex> message = Pretty.From.term("message")
      iex> Pretty.Compose.card(label, message) |> to_string
      "╭─────────╮\n│ label   │\n├─────────┤\n│ message │\n╰─────────╯"

  ## Options

    see `grid/2`
  """
  @spec card(Pretty.Canvas.t(), Pretty.Canvas.t()) :: Pretty.Canvas.t()
  def card(label, message, options \\ []) do
    table([label], [[message]], options)
  end

  @doc ~S"""
  Returns a canvas with a pretty map given a `canvas_map`.

  The `canvas_map` must be a map with both Pretty.Canvas as keys and values.

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
  Returns a canvas with a pretty map given a `canvas_map`.

  The `canvas_map` must be a map with both Pretty.Canvas as keys and values.

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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, [0, 0, 0, 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [0, 1, 0, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty list given a `canvas_list`

  The `canvas_list` must be a list of Pretty.Canvas.

  ## Options

    see `grid/4`

  ## Examples

      iex> canvas_list = [Pretty.From.term("1"), Pretty.From.term("2")]
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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a plain list given a `canvas_list`

  The `canvas_list` must be a list of Pretty.Canvas.

  ## Options

    see `grid/4`

  ## Examples

      iex> canvas_list = [Pretty.From.term("1"), Pretty.From.term("2"), Pretty.From.term("3")]
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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_items, [0, 0, 0, 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [0, 1, 0, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty tuple given `canvas_tuple`

  The `canvas_tuple` must be a tuple of Pretty.Canvas.

  ## Options

    see `grid/4`

  ## Examples

      iex> canvas_tuple = {Pretty.From.term("1"), Pretty.From.term("2")}
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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :center)

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [1, 1, 1, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a plain tuple given `canvas_list`

  The `canvas_tuple` must be a tuple of Pretty.Canvas.

  ## Options

    see `grid/4`

  ## Examples

      iex> canvas_tuple = {Pretty.From.term("1"), Pretty.From.term("2"), Pretty.From.term("3")}
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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 0)
      |> Keyword.put_new(:pad_grid, [0, 1, 0, 1])
      |> Keyword.put_new(:pad_items, [0, 0, 0, 0])

    Pretty.Compose.Grid.compose(
      canvas_list,
      1,
      [length(canvas_list)],
      lines_renderer,
      [0, 1, 0, 1],
      options
    )
  end

  @doc ~S"""
  Returns a canvas with a pretty math matrix given a `canvas_matrix`

  The `canvas_matrix` must be a list of list of Pretty.Canvas.

  ## Options

    see `grid/4`

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
      |> Pretty.Canvas.overlay_all()
    end

    options =
      options
      |> Keyword.put_new(:column_gap, 1)
      |> Keyword.put_new(:row_gap, 1)
      |> Keyword.put_new(:pad_items, [0, 1, 0, 1])
      |> Keyword.put_new(:align_items, :center)
      |> Keyword.put_new(:justify_items, :right)

    Pretty.Compose.Grid.compose(
      canvas_list,
      rows,
      nth_row_column_counts,
      lines_renderer,
      [1, 1, 1, 1],
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
