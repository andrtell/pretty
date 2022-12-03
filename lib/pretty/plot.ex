defmodule Pretty.Plot do
  @moduledoc false

  @doc ~S"""
  Computes the points on a line between two points using the Bresenham
  line plotting algorithm.

  The `from` and `to` arguments should be tuples of the form `{x, y}`
  representing the starting and ending coordinates of the line,
  respectively.

  The return value is a list of points in the form `{x, y}` that
  represent the coordinates of the line.

  ## Examples

    iex> Pretty.Plot.line({0, 1}, {6, 4})
    [{0, 1}, {1, 1}, {2, 2}, {3, 2}, {4, 3}, {5, 3}, {6, 4}]
  """
  @spec line({integer, integer}, {integer, integer}) :: [{integer, integer}]
  def line({x0, y0} = _from, {x1, y1} = _to) do
    dx = x1 - x0
    dy = y1 - y0

    low_slope = abs(dy) < abs(dx)

    {x0, x1, dx, dy, y0} =
      if low_slope do
        if dx > 0,
          do: {x0, x1, dx, dy, y0},
          else: {x1, x0, -dx, -dy, y1}
      else
        if dy > 0,
          do: {y0, y1, dy, dx, x0},
          else: {y1, y0, -dy, -dx, x1}
      end

    x_range = Enum.to_list(x0..x1)

    y_inc = if dy > 0, do: 1, else: -1

    dy = abs(dy)

    y_plot = line_rec(x_range, [], y0, 2 * dy - dx, y_inc, dx, dy)

    if low_slope, do: Enum.zip(x_range, y_plot), else: Enum.zip(y_plot, x_range)
  end

  defp line_rec([], y_plot, _, _, _, _, _), do: Enum.reverse(y_plot)

  defp line_rec([_ | x_range], y_plot, y, derr, y_inc, dx, dy) do
    y_plot = [y | y_plot]

    if derr > 0,
      do: line_rec(x_range, y_plot, y + y_inc, derr + 2 * (dy - dx), y_inc, dx, dy),
      else: line_rec(x_range, y_plot, y, derr + 2 * dy, y_inc, dx, dy)
  end

  @doc ~S"""
  Returns the points on a circle given the `radius`.

  The `radius` must be a positive integer.

  Note that the circle is always centered at the origin (0, 0).
  """
  @spec circle(integer) :: [{integer, integer}]
  def circle(radius) do
    circle_rec(0, radius, 3 - 2 * radius, [])
  end

  defp circle_rec(x, y, _, points) when x > y, do: points

  defp circle_rec(x, y, derr, points) do
    points = [{x, y}, {x, -y}, {-x, y}, {-x, -y}, {y, x}, {y, -x}, {-y, x}, {-y, -x} | points]

    if derr > 0,
      do: circle_rec(x + 1, y - 1, derr + 4 * (x - y) + 10, points),
      else: circle_rec(x + 1, y, derr + 4 * x + 6, points)
  end

  @doc ~S"""
  Returns the points in a solid circle given `radius`

  The `radius` must be a positive integer.

  Note that the circle is always centered at the origin (0, 0).
  """
  @spec circle_solid(integer) :: [{integer, integer}]
  def circle_solid(radius) do
    circle_solid_rec(0, radius, 3 - 2 * radius, [])
  end

  defp circle_solid_rec(x, y, _, points) when x > y do
    List.flatten(points)
  end

  defp circle_solid_rec(x, y, derr, points) do
    points = [
      for(a <- y..-y, do: {x, a}),
      for(b <- y..-y, do: {-x, b}),
      for(c <- x..-x, do: {y, c}),
      for(d <- x..-x, do: {-y, d}) | points
    ]

    if derr > 0,
      do: circle_solid_rec(x + 1, y - 1, derr + 4 * (x - y) + 10, points),
      else: circle_solid_rec(x + 1, y, derr + 4 * x + 6, points)
  end
end
