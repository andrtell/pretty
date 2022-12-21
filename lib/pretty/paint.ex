defmodule Pretty.Paint do
  alias Pretty.Canvas
  alias Pretty.Plot
  alias Pretty.Symbols

  @moduledoc false

  @doc ~S"""
  Returns a canvas with a single pixel.

  ## Examples

      iex> Pretty.Paint.dot("x") |> to_string
      "x" 
  """
  @spec dot(String.t()) :: Canvas.t()
  def dot(filler \\ "·") do
    dot_at({0, 0}, filler)
  end

  @doc ~S"""
  Returns a canvas with a single pixel.

  ## Examples

      iex> Pretty.Paint.dot_at({0, 0}, "x") |> to_string
      "x" 
  """
  @spec dot_at({integer, integer}, String.t()) :: Canvas.t()
  def dot_at(point, filler \\ "·") do
    Canvas.from_points(filler, [point])
  end

  @doc ~S"""
  Returns a canvas with a line.

  ## Examples

      iex> Pretty.Paint.line({0, 0}, {2, 2}, "x") |> to_string
      "x  \n x \n  x"
  """
  @spec line({integer, integer}, {integer, integer}, String.t()) :: Canvas.t()
  def line({x0, y0} = p1, {x1, y1} = p2, filler \\ "·") do
    cond do
      p1 == p2 -> dot_at(p1, filler)
      y0 == y1 -> horizontal_line_at(p1, p2, filler)
      x0 == x1 -> vertical_line_at(p1, p2, filler)
      true -> Canvas.from_points(filler, Plot.line(p1, p2))
    end
  end

  defp horizontal_line_at({x0, y0}, {x1, _}, filler) do
    Canvas.from_points(filler, for(x <- x0..x1, do: {x, y0}))
  end

  defp vertical_line_at({x0, y0}, {_, y1}, filler) do
    Canvas.from_points(filler, for(y <- y0..y1, do: {x0, y}))
  end

  @doc ~S"""
  Returns a canvas with a polygon.

  ## Examples

      iex> Pretty.Paint.polygon([{0, 0}, {2, 0}, {2, 2}], "x") |> to_string
      "xxx\n xx\n  x"
  """
  @spec polygon([{integer, integer}], String.t()) :: Canvas.t()
  def polygon([first_point | rest] = points, filler \\ "·") do
    last_point = List.last(rest)

    [
      for({p1, p2} <- Enum.zip(points, rest), do: line(p1, p2, filler)),
      line(first_point, last_point, filler)
    ]
    |> List.flatten()
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a triangle.

  ## Examples

      iex> Pretty.Paint.triangle({0, 0}, {2, 0}, {2, 2}, "x") |> to_string
      "xxx\n xx\n  x"
  """
  @spec triangle({integer, integer}, {integer, integer}, {integer, integer}, String.t()) ::
          Canvas.t()
  def triangle(p1, p2, p3, filler \\ "·") do
    polygon([p1, p2, p3], filler)
  end

  @doc ~S"""
  Returns a canvas with a rectangle.

  ## Examples

      iex> Pretty.Paint.rectangle({0, 0}, {2, 2}, "x") |> to_string
      "xxx\nx x\nxxx"
  """
  @spec rectangle({integer, integer}, {integer, integer}, String.t()) :: Canvas.t()
  def rectangle({x0, y0} = _top_left, {x1, y1} = _bottom_right, filler \\ "·") do
    polygon([{x0, y0}, {x1, y0}, {x1, y1}, {x0, y1}], filler)
  end

  @doc ~S"""
  Returns a canvas with a solid rectangle.

  ## Examples

      iex> Pretty.Paint.rectangle_solid({0, 0}, {2, 2}, "x") |> to_string
      "xxx\nxxx\nxxx"
  """
  @spec rectangle_solid({integer, integer}, {integer, integer}, String.t()) :: Canvas.t()
  def rectangle_solid({x0, y0} = _top_left, {x1, y1} = _bottom_right, filler \\ "·") do
    points = for x <- x0..x1, y <- y0..y1, do: {x, y}
    Canvas.from_points(filler, points)
  end

  @doc ~S"""
  Returns a canvas with a circle

  ## Examples

      iex> Pretty.Paint.circle({0, 0}, 2, "x") |> to_string
      " xxx \nx   x\nx   x\nx   x\n xxx "
  """
  @spec circle({integer, integer}, integer, String.t()) :: Canvas.t()
  def circle({x0, y0} = _center, r, filler \\ "·") do
    Canvas.from_points(filler, Plot.circle(r))
    |> Canvas.translate(x0, y0)
  end

  @doc ~S"""
  Returns a canvas with a solid circle.

  ## Examples

      iex> Pretty.Paint.circle_solid({0, 0}, 2, "x") |> to_string
      " xxx \nxxxxx\nxxxxx\nxxxxx\n xxx "
  """
  @spec circle_solid({integer, integer}, integer, String.t()) :: Canvas.t()
  def circle_solid({x0, y0} = _center, r, filler \\ "?") do
    Canvas.from_points(filler, Plot.circle_solid(r))
    |> Canvas.translate(x0, y0)
  end

  @doc ~S"""
  Returns a canvas with a left hand bracket.

  ## Examples

      iex> Pretty.Paint.bracket_left({0, 0}, {0, 2}) |> to_string
      "╭\n│\n╰"
  """
  @spec bracket_left({integer, integer}, {integer, integer}) :: Canvas.t()
  def bracket_left(top, bottom = _bottom, options \\ []) do
    t = Keyword.get(options, :symbols, Symbols.box())

    [
      line(top, bottom, Map.get(t, :vertical, "?")),
      dot_at(top, Map.get(t, :down_and_right, "?")),
      dot_at(bottom, Map.get(t, :up_and_right, "?"))
    ]
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a right hand bracket.

  ## Examples

      iex> Pretty.Paint.bracket_right({0, 0}, {0, 2}) |> to_string
      "╮\n│\n╯"
  """
  @spec bracket_right({integer, integer}, {integer, integer}) :: Canvas.t()
  def bracket_right(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbols, Symbols.box())

    [
      line(top, bottom, Map.get(t, :vertical, "?")),
      dot_at(top, Map.get(t, :down_and_left, "?")),
      dot_at(bottom, Map.get(t, :up_and_left, "?"))
    ]
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a left hand curly bracket.

  ## Examples

      iex> Pretty.Paint.curly_bracket_left({0, 0}, {0, 2}) |> to_string
      "╭\n┤\n╰"
  """
  @spec curly_bracket_left({integer, integer}, {integer, integer}) :: Canvas.t()
  def curly_bracket_left(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbols, Symbols.box())

    canvas = bracket_left(top, bottom, options)
    [x0, y0, _, y1] = Canvas.box(canvas)
    ym = div(y0 + y1, 2)

    [
      canvas,
      dot_at({x0, ym}, Map.get(t, :vertical_and_left, "?"))
    ]
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a right hand curly bracket.

  ## Examples

      iex> Pretty.Paint.curly_bracket_right({0, 0}, {0, 2}) |> to_string
      "╮\n├\n╯"
  """
  @spec curly_bracket_right({integer, integer}, {integer, integer}) :: Canvas.t()
  def curly_bracket_right(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbols, Symbols.box())

    canvas = bracket_right(top, bottom, options)
    [_, y0, x1, y1] = Canvas.box(canvas)
    ym = div(y0 + y1, 2)

    [
      canvas,
      dot_at({x1 - 1, ym}, Map.get(t, :vertical_and_right, "?"))
    ]
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a grid lines given by `lines_map`
  """

  def grid_lines(
        %{
          horizontals: horizontals,
          verticals: verticals,
          intersects: intersects,
          corners: corners
        } = _line_map,
        options \\ []
      ) do
    t = Keyword.get(options, :symbols, Symbols.box())

    [
      for({p1, p2} <- verticals, do: line(p1, p2, Map.get(t, :vertical, "?"))),
      for({p1, p2} <- horizontals, do: line(p1, p2, Map.get(t, :horizontal, "?"))),
      for({p, v} <- intersects, do: dot_at(p, Map.get(t, v, "?"))),
      for({p, v} <- corners, do: dot_at(p, Map.get(t, v, "?")))
    ]
    |> List.flatten()
    |> Canvas.overlay()
  end

  @doc ~S"""
  Returns a canvas with a dinosaur.
  """
  @spec dinosaur() :: Canvas.t()
  def dinosaur() do
    Canvas.from_string(~S"""
             ██▄▄
             ██▀▀
           ▄███▄
         ▄█████
    ▀▄▄▀▀  █▄ █▄
    """)
  end
end
