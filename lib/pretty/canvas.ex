defmodule Pretty.Canvas do
  @moduledoc false

  alias Pretty.Canvas.Pixel
  alias Pretty.Canvas.Box

  defstruct pixels: nil, box: nil, meta: nil

  @type t :: %__MODULE__{
          box: Box.t(),
          meta: map(),
          pixels: [Pixel.t()]
        }

  defp new(pixels, box) do
    %__MODULE__{pixels: pixels, box: box, meta: %{}}
  end

  @doc ~S"""
  Returns an empty canvas.
  """
  def empty() do
    new([], [0, 0, 0, 0])
  end

  @doc ~S"""
  Returns a new canvas from a `string` and a `point`.

  The `point` is optional and defaults to `{0, 0}`.

  ## Examples

      iex> Pretty.Canvas.from_string("x") |> to_string
      "x"
  """
  @spec from_string(String.t(), {integer, integer}) :: t()
  def from_string(""), do: empty()

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
  Returns a new canvas from a list of `points` and a `filler`.

  ## Examples

      iex> Pretty.Canvas.from_points("+", [{0, 0}, {1, 1}]) |> to_string
      "+ \n +"
  """
  @spec from_points(String.t(), [{integer, integer}]) :: t()
  def from_points(_, []), do: empty()

  def from_points(filler, points) do
    filler = String.at(filler, 0)

    pixels =
      for point <- points,
          do: Pixel.new(filler, point),
          into: []

    box = Box.from_points(points)
    new(pixels, box)
  end

  @doc ~S"""
  Puts the given `value` under `key` in the meta data of the given `canvas`.
  """
  def put_meta(%__MODULE__{meta: meta} = canvas, key, value) do
    %__MODULE__{canvas | meta: Map.put(meta, key, value)}
  end

  @doc ~S"""
  Returns the box of the given `canvas`.
  """
  @spec box(t()) :: Box.t()
  def box(%__MODULE__{box: box}), do: box

  @doc ~S"""
  Translates the given `canvas` by `dx` and `dy`.

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

  @doc ~S"""
  Translates the given `canvas` such that its top left corner ends up at `{0, 0}`.

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
  Pads the given `canvas`.

  ## Examples

      iex> canvas = Pretty.Canvas.from_string("x", {0, 0})
      iex> canvas = Pretty.Canvas.pad(canvas, top: 1, left: 1, right: 1, bottom: 1)
      iex> Pretty.Canvas.box(canvas)
      [0, 0, 3, 3]
  """
  @spec pad(t(), Keyword.t()) :: t()
  def pad(canvas, options) do
    top = max(Keyword.get(options, :top, 0), 0)
    right = max(Keyword.get(options, :right, 0), 0)
    bottom = max(Keyword.get(options, :bottom, 0), 0)
    left = max(Keyword.get(options, :left, 0), 0)

    pixels = translate_pixels(canvas.pixels, left, top)
    box = Box.grow(canvas.box, right + left, top + bottom)
    new(pixels, box)
  end

  defp translate_pixels(pixels, 0, 0) do
    pixels
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
  Overlays the given canvas `over` on top of the given canvas `under`.

  ## Examples

      iex> under = Pretty.Canvas.from_string("xx")
      iex> over = Pretty.Canvas.from_string("oo", {0, 1})
      iex> Pretty.Canvas.overlay(under, over) |> to_string
      "xx\noo"
  """
  @spec overlay(t(), t()) :: t()
  def overlay(under, over) do
    pixels = [over.pixels | under.pixels]
    box = Box.from_boxes([box(over), box(under)])
    new(pixels, box)
  end

  @doc ~S"""
  Overlays all the given `canvases` on top of each other from left to right.

  ## Examples
      iex> under = Pretty.Canvas.from_string("xx")
      iex> over1 = Pretty.Canvas.from_string("oo", {0, 1})
      iex> over2 = Pretty.Canvas.from_string("--", {0, 2})
      iex> Pretty.Canvas.overlay([under, over1, over2]) |> to_string
      "xx\noo\n--"
  """
  @spec overlay([t()]) :: t()
  def overlay([]), do: empty()

  def overlay(canvases) do
    [base | overlays] = canvases
    Enum.reduce(overlays, base, fn a, b -> overlay(b, a) end)
  end

  @doc ~S"""
  Converts the given `canvas` to IO.chardata().

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

    pixel_map = for pixel <- pixels, do: {Pixel.point(pixel), Pixel.value(pixel)}, into: %{}

    lines =
      for y <- ymin..(ymax - 1) do
        [
          for x <- xmin..(xmax - 1) do
            Map.get(pixel_map, {x, y}, filler)
          end
        ]
      end

    Enum.intersperse(lines, [?\n])
  end

  @doc ~S"""
  Returns a string given a `canvas`

  ## Examples

      iex> Pretty.Canvas.from_string("x") |> Pretty.Canvas.to_string()
      "x"
  """
  @spec to_string(t()) :: String.t()
  def to_string(canvas, filler \\ " ") do
    to_chardata(canvas, filler) |> IO.iodata_to_binary()
  end
end
