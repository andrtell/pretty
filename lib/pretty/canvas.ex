defmodule Pretty.Canvas do
  alias Pretty.Canvas.Pixel
  alias Pretty.Canvas.Box

  defstruct pixels: nil, box: nil, meta: nil

  @type t :: %__MODULE__{
          pixels: [Pixel.t()],
          box: Box.t(),
          meta: Map.t()
        }

  # returns new canvas.
  defp new(pixels, box) do
    %__MODULE__{pixels: pixels, box: box, meta: %{}}
  end

  @doc ~S"""
  Returns an empty canvas
  """
  def empty() do
    new([], [0, 0, 0, 0])
  end

  @doc ~S"""
  Returns a new canvas given a `string` and a `point`.

  The `point` is optional and defaults to `{0, 0}`.

  ## Examples

      iex> Pretty.Canvas.from_string("x") |> to_string
      "x"
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

    box = Box.new(x0, y0, width, height)

    pixels =
      for {line, y} <- Enum.with_index(lines),
          {value, x} <- Enum.with_index(String.codepoints(line)),
          do: Pixel.new(value, {x + x0, y + y0}),
          into: []

    new(pixels, box)
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
    pixels =
      for point <- points,
          do: Pixel.new(filler, point),
          into: []

    box = Box.from_points(points)
    new(pixels, box)
  end

  @doc ~S"""
  Returns the box of the given `canvas`.
  """
  @spec box(t()) :: Box.t()
  def box(%__MODULE__{box: box}), do: box

  @doc ~S"""
  Returns the pixels of the given `canvas`.
  """
  @spec pixels(t()) :: [Pixel.t()]
  def pixels(%__MODULE__{pixels: pixels}), do: pixels

  @doc ~S"""
  Returns the meta of the given `canvas`.
  """
  def meta(%__MODULE__{meta: meta}), do: meta

  @doc ~S"""
  Returns a new canvas with the given `key` and `value` added.
  """
  def put_meta(%__MODULE__{meta: meta} = canvas, key, value) do
    %__MODULE__{canvas | meta: Map.put(meta, key, value)}
  end

  @doc ~S"""
  Returns a new canvas by combining the given `base` and `overlay`.

  ## Examples

      iex> base = Pretty.Canvas.from_string("xx")
      iex> overlay = Pretty.Canvas.from_string("oo", {0, 1})
      iex> Pretty.Canvas.overlay(base, overlay) |> to_string
      "xx\noo"
  """
  @spec overlay(t(), t()) :: t()
  def overlay(base, overlay) do
    pixels = [overlay.pixels | base.pixels]
    box = Box.from_boxes([box(base), box(overlay)])
    new(pixels, box)
  end

  @doc ~S"""
  Returns a new canvas by combining all the given `canvases` from left to right.

  ## Examples
      iex> base = Pretty.Canvas.from_string("xx")
      iex> overlay1 = Pretty.Canvas.from_string("oo", {0, 1})
      iex> overlay2 = Pretty.Canvas.from_string("--", {0, 2})
      iex> Pretty.Canvas.overlay([base, overlay1, overlay2]) |> to_string
      "xx\noo\n--"
  """
  @spec overlay([t()]) :: t()
  def overlay([]), do: empty()

  def overlay(canvases) do
    [base | overlays] = canvases
    Enum.reduce(overlays, base, fn a, b -> overlay(b, a) end)
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
      iex> Pretty.Canvas.translate(canvas, 1, 1) |> Pretty.Canvas.box
      [1, 1, 2, 2]
  """
  @spec translate(t(), integer, integer) :: t()
  def translate(canvas, 0, 0), do: canvas

  def translate(canvas, dx, dy) do
    pixels = translate_pixels(canvas.pixels, dx, dy)
    box = Box.translate(canvas.box, dx, dy)
    new(pixels, box)
  end

  defp translate_pixels(pixels, dx, dy) do
    for elem <- pixels do
      case elem do
        %Pixel{} -> Pixel.translate(elem, dx, dy)
        _ -> translate_pixels(elem, dx, dy)
      end
    end
  end

  @doc ~S"""
  Translates `canvas` such that its top left corner is at `{0, 0}`.

  ## Examples

      iex> canvas = Pretty.Canvas.from_string("x", {1, 1})
      iex> Pretty.Canvas.translate_origin(canvas) |> Pretty.Canvas.box
      [0, 0, 1, 1]
  """
  def translate_origin(canvas) do
    {dx, dy} = Box.min_point(canvas.box)
    translate(canvas, -dx, -dy)
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
    [xmin, ymin, xmax, ymax] = box(canvas)
    pixels = List.flatten(canvas.pixels) |> Enum.reverse()
    map = for pixel <- pixels, do: {Pixel.point(pixel), Pixel.value(pixel)}, into: %{}

    lines =
      for y <- ymin..(ymax - 1) do
        [
          for x <- xmin..(xmax - 1) do
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
