defmodule Pretty.Canvas do
  defstruct dots: nil, bounding_box: nil

  @type dot :: {{integer, integer}, String.t()}
  @type bounding_box :: [integer]

  @type t :: %__MODULE__{
          dots: [dot],
          bounding_box: bounding_box
        }

  # returns new canvas.
  defp new(dots, bounding_box) do
    %__MODULE__{dots: dots, bounding_box: bounding_box}
  end

  @doc ~S"""
  Returns an empty canvas
  """
  def empty() do
    new([], [0, 0, 0, 0])
  end

  @doc ~S"""
  Returns a new canvas given a `str` and an optional `location`.

  The `str` is a string.

  The `location` must be a tuple of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Canvas.from_string("A \n B") |> to_string
      "A \n B"
  """
  @spec from_string(String.t(), {integer, integer}) :: t()
  def from_string(str, {x0, y0} = _location \\ {0, 0}) do
    lines =
      str
      |> String.trim_trailing("\n")
      |> String.split("\n")

    height =
      lines
      |> length

    width =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max()

    bounding_box = [x0, y0, x0 + width, y0 + height]

    dots =
      for {line, y} <- Enum.with_index(lines),
          {symbol, x} <- Enum.with_index(String.codepoints(line)),
          do: {{x + x0, y + y0}, symbol},
          into: []

    new(dots, bounding_box)
  end

  @doc ~S"""
  Returns a new canvas given `points` and `filler`

  The `points` must be a list of tuples of the form `{x, y}` where `x` and `y` are integers.

  The `filler` must be a string of length 1.

  ## Examples

      iex> Pretty.Canvas.from_points([{0, 0}, {1, 1}], "+") |> to_string
      "+ \n +"
  """
  @spec from_points([{integer, integer}], String.t()) :: t()
  def from_points(points, filler \\ "·") do
    dots =
      for point <- points,
          do: {point, filler},
          into: []

    bounding_box = calculate_points_bounding_box(points)
    new(dots, bounding_box)
  end

  @doc ~S"""
  Returns a new canvas given `canvas1` and `canvas2` with `canvas2` drawn on 
  top of `canvas1`.

  ## Examples

      iex> canvas1 = Pretty.Canvas.from_string("xx")
      iex> canvas2 = Pretty.Canvas.from_string("oo", {0, 1})
      iex> Pretty.Canvas.overlay(canvas1, canvas2) |> to_string
      "xx\noo"
  """
  @spec overlay(t(), t()) :: t()
  def overlay(canvas1, canvas2) do
    dots = [canvas2.dots | canvas1.dots]
    bounding_box = bounding_box_all([canvas1, canvas2])
    new(dots, bounding_box)
  end

  @doc ~S"""
  Returns a new canvas given `canvases` with all canvases in `canvases`
  overlayed from left to right.

  ## Examples
      iex> canvas1 = Pretty.Canvas.from_string("xx")
      iex> canvas2 = Pretty.Canvas.from_string("oo", {0, 1})
      iex> canvas3 = Pretty.Canvas.from_string("--", {0, 2})
      iex> Pretty.Canvas.overlay_all([canvas1, canvas2, canvas3]) |> to_string
      "xx\noo\n--"
  """
  @spec overlay_all([t()]) :: t()
  def overlay_all([]), do: empty()

  def overlay_all(canvases) do
    [c0 | rest] = canvases
    Enum.reduce(rest, c0, fn a, b -> overlay(b, a) end)
  end

  @doc ~S"""
  Returns a new canvas given `canvas` and `dx` and `dy` such that `canvas` is 
  translated by `dx` horizontally and `dy` vertically.

  The `canvas` must be a Pretty.Canvas.
  The `dx` and `dy` must be integers.

  This function is only really useful for when combining canvases with 
  `overlay/2` and `overlay_all/1`.

  ## Examples

      iex> canvas = Pretty.Canvas.from_string("x", {0, 0})
      iex> Pretty.Canvas.translate(canvas, 1, 1) |> Pretty.Canvas.bounding_box
      [1, 1, 2, 2]
  """
  @spec translate(t(), integer, integer) :: t()
  def translate(canvas, 0, 0), do: canvas

  def translate(canvas, dx, dy) do
    dots = translate_dots(canvas.dots, dx, dy)
    [xmin, ymin, xmax, ymax] = bounding_box(canvas)
    bounding_box = [xmin + dx, ymin + dy, xmax + dx, ymax + dy]
    new(dots, bounding_box)
  end

  defp translate_dots(dots, dx, dy) do
    for elem <- dots do
      case elem do
        {{x, y}, symbol} -> {{x + dx, y + dy}, symbol}
        _ -> translate_dots(elem, dx, dy)
      end
    end
  end

  @doc ~S"""
  Translates `canvas` such that its bounding box is at the origin.
  """
  def translate_origin(canvas) do
    [dx, dy, _, _] = bounding_box(canvas)
    translate(canvas, -dx, -dy)
  end

  @doc ~S"""
  Returns the bounding box of the given canvas.

  The last two values of the bounding-box is non-inclusive.

  ## Examples

      iex> Pretty.Paint.line({0,0}, {2,2})
      ...> |> Pretty.Canvas.bounding_box()
      [0, 0, 3, 3]
  """
  @spec bounding_box(t()) :: [integer]
  def bounding_box(c) do
    c.bounding_box
  end

  @doc ~S"""
  Returns the combined bounding box of a list of canvases.

  ## Examples

      iex> Pretty.Canvas.bounding_box_all(
      ...>  [
      ...>    Pretty.Paint.line({0,0}, {2,2}), 
      ...>    Pretty.Paint.line({4, 4}, {5, 5})
      ...>  ]
      ...> )
      [0, 0, 6, 6]
  """
  @spec bounding_box_all([t()]) :: [integer]
  def bounding_box_all([]), do: [0, 0, 0, 0]

  def bounding_box_all([_ | _] = canvases) do
    Enum.reduce(
      canvases,
      [0, 0, 0, 0],
      fn c, [x_min, y_min, x_max, y_max] ->
        [x0, y0, x1, y1] = bounding_box(c)
        [min(x_min, x0), min(y_min, y0), max(x_max, x1), max(y_max, y1)]
      end
    )
  end

  @doc ~S"""
  Returns a bounding box given `points`.

  The `points` must be a list of tuples of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Canvas.calculate_points_bounding_box([{0, 0}, {1, 1}])
      [0, 0, 2, 2]
  """
  @spec calculate_points_bounding_box([{integer, integer}]) :: [integer]
  def calculate_points_bounding_box([]), do: [0, 0, 0, 0]

  def calculate_points_bounding_box([{x0, y0} | rest]) do
    {x_min, y_min, x_max, y_max} =
      Enum.reduce(
        rest,
        {x0, y0, x0, y0},
        fn {x, y}, {min_x, min_y, max_x, max_y} ->
          {min(min_x, x), min(min_y, y), max(max_x, x), max(max_y, y)}
        end
      )

    [x_min, y_min, x_max + 1, y_max + 1]
  end

  @doc ~S"""
  Returns the width of the given `canvas`.

  The `canvas` must be a Pretty.Canvas.

  ## Examples

      iex> Pretty.Canvas.from_string("xx")
      ...> |> Pretty.Canvas.width()
      2
  """
  @spec width(t()) :: integer
  def width(c) do
    [x_min, _, x_max, _] = bounding_box(c)
    x_max - x_min
  end

  @doc ~S"""
  Returns the height of the given `canvas`.

  The `canvas` must be a Pretty.Canvas.

  ## Examples

      iex> Pretty.Canvas.from_string("xx\noo")
      ...> |> Pretty.Canvas.height()
      2
  """
  @spec height(t()) :: integer
  def height(c) do
    [_, y_min, _, y_max] = bounding_box(c)
    y_max - y_min
  end

  @doc ~S"""
  Convert the given `canvas` to a chardata.

  The `canvas` must be a Pretty.Canvas.

  ## Examples

      iex> Pretty.Canvas.from_string("xx\noo")
      ...> |> Pretty.Canvas.to_chardata()
      [[["x", "x"]], '\n', [["o", "o"]]]
  """
  @spec to_chardata(t()) :: IO.chardata()
  def to_chardata([]), do: []

  def to_chardata(canvas, filler \\ " ") do
    [x_min, y_min, x_max, y_max] = bounding_box(canvas)
    dots = List.flatten(canvas.dots) |> Enum.reverse()
    map = for {k, v} <- dots, do: {k, v}, into: %{}

    lines =
      for y <- y_min..(y_max - 1) do
        [
          for x <- x_min..(x_max - 1) do
            Map.get(map, {x, y}, filler)
          end
        ]
      end

    Enum.intersperse(lines, [?\n])
  end

  @doc ~S"""
  Returns a list of strings given `canvas`

  The `canvas` must be a Pretty.Canvas.

  ## Examples

      iex> Pretty.Canvas.from_string("xx\noo")
      ...> |> Pretty.Canvas.to_string_rows()
      ["xx", "oo"]
  """
  @spec to_string_rows(t()) :: [String.t()]
  def to_string_rows(canvas, filler \\ " ") do
    to_chardata(canvas, filler)
    |> Enum.map(fn line -> IO.iodata_to_binary(line) end)
    |> Enum.filter(fn line -> line != "\n" end)
  end

  @doc ~S"""
  Returns a string given `canvas`

  The `canvas` must be a Pretty.Canvas.

  ## Examples

      iex> Pretty.Canvas.from_string("xx\noo")
      ...> |> Pretty.Canvas.to_string()
      "xx\noo"
  """
  @spec to_string(t()) :: String.t()
  def to_string(canvas, filler \\ " ") do
    to_chardata(canvas, filler) |> IO.iodata_to_binary()
  end

  @doc ~S"""
  Prints the given `canvas` with missing points in the bounding box filled out
  with the given `filler`.

  The `canvas` must be a Pretty.Canvas.
  The `filler` must be a string.
  """
  @spec print(t(), String.t()) :: :ok
  def print(c, filler \\ " ") do
    c |> to_chardata(filler) |> IO.puts()
  end
end
