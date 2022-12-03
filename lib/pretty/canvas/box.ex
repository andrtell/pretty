defmodule Pretty.Canvas.Box do
  @moduledoc false

  @type t :: [integer]

  # The box is encoded as [x0, y0, x1, y1] and NOT as [x0, y0, width, height]
  # x1 and y1 are exclusive.

  @doc ~S"""
  Returns a new box given the coordinates of the top-left corner 
  `x` and `y` and the `width` and `height`.

  ## Examples

      iex> Pretty.Canvas.Box.new(0, 0, 1, 1)
      [0, 0, 1, 1]
  """
  def new(x0, y0, width, height) do
    [x0, y0, x0 + width, y0 + height]
  end

  @doc ~S"""
  Returns an empty box.
  """
  @spec empty() :: t()
  def empty() do
    [0, 0, 0, 0]
  end

  @doc ~S"""
  Returns true if the given `box` is empty.
  """
  @spec empty?(t()) :: boolean
  def empty?(box) do
    box == empty()
  end

  @doc ~S"""
  Returns a new box that spans the given `boxes`.

  ## Examples

      iex> Pretty.Canvas.Box.from_boxes([[0, 0, 1, 1], [1, 1, 2, 2]])
      [0, 0, 2, 2]
  """
  @spec from_boxes([t()]) :: t()
  def from_boxes([]), do: empty()

  def from_boxes(boxes) do
    Enum.reduce(
      boxes,
      [0, 0, 0, 0],
      fn [x0, y0, x1, y1], [xmin, ymin, xmax, ymax] ->
        [min(xmin, x0), min(ymin, y0), max(xmax, x1), max(ymax, y1)]
      end
    )
  end

  @doc ~S"""
  Returns a new box that spans the given `points`.

  ## Examples

      iex> Pretty.Canvas.Box.from_points([{0, 0}, {1, 1}])
      [0, 0, 2, 2]
  """
  @spec from_points([{integer, integer}]) :: t()
  def from_points([]), do: empty()

  def from_points([{x0, y0} | ps] = _points) do
    {xmin, ymin, xmax, ymax} =
      Enum.reduce(
        ps,
        {x0, y0, x0, y0},
        fn {x, y}, {xmin, ymin, xmax, ymax} ->
          {min(xmin, x), min(ymin, y), max(xmax, x), max(ymax, y)}
        end
      )

    [xmin, ymin, xmax + 1, ymax + 1]
  end

  @doc ~S"""
  Returns the min-point of the given `box`.

  ## Examples

      iex> Pretty.Canvas.Box.min_point([0, 0, 1, 2])
      {0, 0}
  """
  @spec min_point(t()) :: {integer, integer}
  def min_point([x0, y0, _x1, _y1]) do
    {x0, y0}
  end

  @doc ~S"""
  Returns the width of the given `box`.

  ## Examples

      iex> Pretty.Canvas.Box.width([0, 0, 1, 2])
      1
  """
  @spec width(t()) :: integer()
  def width([x0, _y0, x1, _y1] = _box) do
    x1 - x0
  end

  @doc ~S"""
  Returns the height of the given `box`.

  ## Examples

      iex> Pretty.Canvas.Box.height([0, 0, 1, 2])
      2
  """
  @spec height(t()) :: integer()
  def height([_x0, y0, _x1, y1] = _box) do
    y1 - y0
  end

  @doc ~S"""
  Translates the given `box` by the given `dx` and `dy`.

  ## Examples

      iex> Pretty.Canvas.Box.translate([0, 0, 1, 1], 2, 2)
      [2, 2, 3, 3]
  """
  @spec translate(t(), integer(), integer()) :: t()
  def translate(box, 0, 0), do: box

  def translate([x0, y0, x1, y1], dx, dy) do
    [x0 + dx, y0 + dy, x1 + dx, y1 + dy]
  end

  @doc ~S"""
  Grows the given `box` by `dx` and `dy` on each side.

  ## Examples

      iex> Pretty.Canvas.Box.grow([0, 0, 1, 1], 1, 1)
      [0, 0, 2, 2]
  """
  @spec grow(t(), integer(), integer()) :: t()
  def grow(box, 0, 0), do: box

  def grow([x0, y0, x1, y1], dx, dy) do
    [x0, y0, x1 + dx, y1 + dy]
  end
end
