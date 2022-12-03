defmodule Pretty.Paint do
  @moduledoc """
  A module for creating Pretty.Canvas from various input
  """

  @doc ~S"""
  Returns a canvas with a single symbol given a `filler`.

  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.dot("x") |> to_string
      "x" 
  """
  @spec dot(String.t()) :: Pretty.Canvas.t()
  def dot(filler \\ "·") do
    dot_at({0, 0}, filler)
  end

  @doc ~S"""
  Returns a canvas with a single symbol given a `point` and `filler`.

  The `point` must be a tuple of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.dot_at({0, 0}, "x") |> to_string
      "x" 
  """
  @spec dot_at({integer, integer}, String.t()) :: Pretty.Canvas.t()
  def dot_at(point, filler \\ "·") do
    if String.length(filler) != 1 do
      raise ArgumentError, message: "filler must be a single character"
    end

    Pretty.Canvas.from_points([point], filler)
  end

  @doc ~S"""
  Returns a canvas with a line given `p1`, `p2` and `filler`.

  The `p1` and `p2` must be tuples of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.line({0, 0}, {2, 2}, "x") |> to_string
      "x  \n x \n  x"
  """
  @spec line({integer, integer}, {integer, integer}, String.t()) :: Pretty.Canvas.t()
  def line({x0, y0} = p1, {x1, y1} = p2, filler \\ "·") do
    cond do
      p1 == p2 -> dot_at(p1, filler)
      y0 == y1 -> horizontal_line_at(p1, p2, filler)
      x0 == x1 -> vertical_line_at(p1, p2, filler)
      true -> Pretty.Canvas.from_points(Pretty.Plot.line(p1, p2), filler)
    end
  end

  defp horizontal_line_at({x0, y0}, {x1, _}, filler) do
    Pretty.Canvas.from_points(for(x <- x0..x1, do: {x, y0}), filler)
  end

  defp vertical_line_at({x0, y0}, {_, y1}, filler) do
    Pretty.Canvas.from_points(for(y <- y0..y1, do: {x0, y}), filler)
  end

  @doc ~S"""
  Returns a canvas with a polygon given `points` and `filler`.

  The `points` must be a list of tuples of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.polygon([{0, 0}, {2, 0}, {2, 2}], "x") |> to_string
      "xxx\n xx\n  x"
  """
  @spec polygon([{integer, integer}], String.t()) :: Pretty.Canvas.t()
  def polygon([first_point | rest] = points, filler \\ "·") do
    last_point = List.last(rest)

    [
      for({p1, p2} <- Enum.zip(points, rest), do: line(p1, p2, filler)),
      line(first_point, last_point, filler)
    ]
    |> List.flatten()
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a triangle given `p1`, `p2` and `p3` and `filler`.

  The `p1`, `p2` and `p3` must be tuples of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.triangle({0, 0}, {2, 0}, {2, 2}, "x") |> to_string
      "xxx\n xx\n  x"
  """
  @spec triangle({integer, integer}, {integer, integer}, {integer, integer}, String.t()) ::
          Pretty.Canvas.t()
  def triangle(p1, p2, p3, filler \\ "·") do
    polygon([p1, p2, p3], filler)
  end

  @doc ~S"""
  Returns a canvas with a rectangle given `top_left`, `bottom_right` and `filler`.

  The `top_left` and `bottom_right` must be tuples of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.rectangle({0, 0}, {2, 2}, "x") |> to_string
      "xxx\nx x\nxxx"
  """
  @spec rectangle({integer, integer}, {integer, integer}, String.t()) :: Pretty.Canvas.t()
  def rectangle({x0, y0} = _top_left, {x1, y1} = _bottom_right, filler \\ "·") do
    polygon([{x0, y0}, {x1, y0}, {x1, y1}, {x0, y1}], filler)
  end

  @doc ~S"""
  Returns a canvas with a filled in rectangle given `top_left`, `bottom_right` and `filler`.

  The `top_left` and `bottom_right` must be tuples of the form `{x, y}` where `x` and `y` are integers.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.rectangle_solid({0, 0}, {2, 2}, "x") |> to_string
      "xxx\nxxx\nxxx"
  """
  @spec rectangle_solid({integer, integer}, {integer, integer}, String.t()) :: Pretty.Canvas.t()
  def rectangle_solid({x0, y0} = _top_left, {x1, y1} = _bottom_right, filler \\ "·") do
    points = for x <- x0..x1, y <- y0..y1, do: {x, y}
    Pretty.Canvas.from_points(points, filler)
  end

  @doc ~S"""
  A short name for `rectangle_solid/3`.

  See `rectangle_solid/3`.
  """
  def block(p1, p2, filler \\ "·") do
    rectangle_solid(p1, p2, filler)
  end

  @doc ~S"""
  Returns a canvas with a circle given `center`, `radius` and `filler`.

  The `center` must be a tuple of the form `{x, y}` where `x` and `y` are integers.
  The `radius` must be an positive integer.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.circle({0, 0}, 2, "x") |> to_string
      " xxx \nx   x\nx   x\nx   x\n xxx "
  """
  @spec circle({integer, integer}, integer, String.t()) :: Pretty.Canvas.t()
  def circle({x0, y0} = _center, r, filler \\ "·") do
    Pretty.Canvas.from_points(Pretty.Plot.circle(r), filler)
    |> Pretty.Canvas.translate(x0, y0)
  end

  @doc ~S"""
  Returns a canvas with a solid circle given `center`, `radius` and `filler`.

  The `center` must be a tuple of the form `{x, y}` where `x` and `y` are integers.
  The `radius` must be an positive integer.
  The `filler` must be a single character string.

  ## Examples

      iex> Pretty.Paint.circle_solid({0, 0}, 2, "x") |> to_string
      " xxx \nxxxxx\nxxxxx\nxxxxx\n xxx "
  """
  @spec circle_solid({integer, integer}, integer, String.t()) :: Pretty.Canvas.t()
  def circle_solid({x0, y0} = _center, r, filler \\ "?") do
    Pretty.Canvas.from_points(Pretty.Plot.circle_solid(r), filler)
    |> Pretty.Canvas.translate(x0, y0)
  end

  @doc ~S"""
  Returns a canvas with a left hand bracket given `top`, `bottom`.

  The `top` and `bottom` must be tuples of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Paint.bracket_left({0, 0}, {0, 2}) |> to_string
      "╭\n│\n╰"
  """
  @spec bracket_left({integer, integer}, {integer, integer}) :: Pretty.Canvas.t()
  def bracket_left(top, bottom = _bottom, options \\ []) do
    t = Keyword.get(options, :symbol_table, Pretty.Symbols.get([:box, :light, :arc]))

    [
      line(top, bottom, Map.get(t, :vertical, "?")),
      dot_at(top, Map.get(t, :down_and_right, "?")),
      dot_at(bottom, Map.get(t, :up_and_right, "?"))
    ]
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a right hand bracket given `top`, `bottom`.

  The `top` and `bottom` must be tuples of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Paint.bracket_right({0, 0}, {0, 2}) |> to_string
      "╮\n│\n╯"
  """
  @spec bracket_right({integer, integer}, {integer, integer}) :: Pretty.Canvas.t()
  def bracket_right(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbol_table, Pretty.Symbols.get([:box, :light, :arc]))

    [
      line(top, bottom, Map.get(t, :vertical, "?")),
      dot_at(top, Map.get(t, :down_and_left, "?")),
      dot_at(bottom, Map.get(t, :up_and_left, "?"))
    ]
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a left hand curly bracket given `top`, `bottom`.

  The `top` and `bottom` must be tuples of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Paint.curly_bracket_left({0, 0}, {0, 2}) |> to_string
      "╭\n┤\n╰"
  """
  @spec curly_bracket_left({integer, integer}, {integer, integer}) :: Pretty.Canvas.t()
  def curly_bracket_left(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbol_table, Pretty.Symbols.get([:box, :light, :arc]))

    canvas = bracket_left(top, bottom, options)
    [x0, y0, _, y1] = Pretty.Canvas.bounding_box(canvas)
    ym = div(y0 + y1, 2)

    [
      canvas,
      dot_at({x0, ym}, Map.get(t, :vertical_and_left, "?"))
    ]
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a right hand curly bracket given `top`, `bottom`.

  The `top` and `bottom` must be tuples of the form `{x, y}` where `x` and `y` are integers.

  ## Examples

      iex> Pretty.Paint.curly_bracket_right({0, 0}, {0, 2}) |> to_string
      "╮\n├\n╯"
  """
  @spec curly_bracket_right({integer, integer}, {integer, integer}) :: Pretty.Canvas.t()
  def curly_bracket_right(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbol_table, Pretty.Symbols.get([:box, :light, :arc]))

    canvas = bracket_right(top, bottom, options)
    [_, y0, x1, y1] = Pretty.Canvas.bounding_box(canvas)
    ym = div(y0 + y1, 2)

    [
      canvas,
      dot_at({x1 - 1, ym}, Map.get(t, :vertical_and_right, "?"))
    ]
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a grid lines given `grid_lines`
  """
  def grid_lines(
        %{
          horizontals: horizontals,
          verticals: verticals,
          intersects: %{
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            cross: cross
          },
          corners: %{
            top_left: top_left,
            top_right: top_right,
            bottom_left: bottom_left,
            bottom_right: bottom_right
          }
        } = _grid_lines_map,
        options \\ []
      ) do
    t = Keyword.get(options, :symbol_table, Pretty.Symbols.get([:box, :light, :arc]))

    [
      for({p1, p2} <- verticals, do: line(p1, p2, Map.get(t, :vertical, "?"))),
      for({p1, p2} <- horizontals, do: line(p1, p2, Map.get(t, :horizontal, "?"))),
      for(p <- cross, do: dot_at(p, Map.get(t, :vertical_and_horizontal, "?"))),
      for(p <- top, do: dot_at(p, Map.get(t, :down_and_horizontal, "?"))),
      for(p <- bottom, do: dot_at(p, Map.get(t, :up_and_horizontal, "?"))),
      for(p <- left, do: dot_at(p, Map.get(t, :vertical_and_right, "?"))),
      for(p <- right, do: dot_at(p, Map.get(t, :vertical_and_left, "?"))),
      dot_at(top_left, Map.get(t, :down_and_right, "?")),
      dot_at(top_right, Map.get(t, :down_and_left, "?")),
      dot_at(bottom_left, Map.get(t, :up_and_right, "?")),
      dot_at(bottom_right, Map.get(t, :up_and_left, "?"))
    ]
    |> List.flatten()
    |> Pretty.Canvas.overlay_all()
  end

  @doc ~S"""
  Returns a canvas with a dinosaur.
  """
  @spec dinosaur() :: Pretty.Canvas.t()
  def dinosaur() do
    Pretty.Canvas.from_string(~S"""
             ██▄▄
             ██▀▀
           ▄███▄
         ▄█████
    ▀▄▄▀▀  █▄ █▄
    """)
  end
end
