defmodule Pretty.Components.Polygon do
  alias Pretty.Canvas

  alias Pretty.Components.Line

  def paint(filler, [first_point | rest] = points) do
    last_point = List.last(rest)

    [
      for({p1, p2} <- Enum.zip(points, rest), do: Line.paint(filler, p1, p2)),
      Line.paint(filler, first_point, last_point)
    ]
    |> List.flatten()
    |> Canvas.overlay()
  end
end
