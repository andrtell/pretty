defmodule Pretty.Canvas.Pixel do
  defstruct value: "",
            point: {0, 0}

  @type t :: %__MODULE__{
          value: String.t(),
          point: Point.t()
        }

  @doc ~S"""
  Returns a new pretty canvas pixel.
  """
  @spec new(String.t(), {integer, integer}) :: t()
  def new(value, point) do
    %__MODULE__{value: value, point: point}
  end

  @doc ~S"""
  Returns the value of the given `pixel`.

  ## Examples

      iex> pixel = Pretty.Canvas.Pixel.new("A", {1, 2})
      ...> Pretty.Canvas.Pixel.value(pixel)
      "A"
  """
  @spec value(t()) :: String.t()
  def value(%__MODULE__{value: value}), do: value

  @doc ~S"""
  Returns the point of the given `pixel`.

  ## Examples

      iex> pixel = Pretty.Canvas.Pixel.new("A", {1, 2})
      ...> Pretty.Canvas.Pixel.point(pixel)
      {1, 2}
  """
  @spec point(t()) :: {integer, integer}
  def point(%__MODULE__{point: point} = _pixel), do: point

  @doc ~S"""
  Returns a new pixel by translating the given `pixel`.

  ## Examples

      iex> p = Pretty.Canvas.Pixel.new("A", {1, 1})
      iex> t = Pretty.Canvas.Pixel.translate(p, 1, 1)
      iex> Pretty.Canvas.Pixel.point(t)
      {2, 2}
  """
  def translate(pixel, dx, dy) do
    {x, y} = point(pixel)
    %__MODULE__{pixel | point: {x + dx, y + dy}}
  end
end
