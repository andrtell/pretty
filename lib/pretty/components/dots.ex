defmodule Pretty.Components.Dots do
  def paint(filler, points) do
    Pretty.Canvas.from_points(filler, points)
  end
end
