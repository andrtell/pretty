defmodule Pretty.Components.DotAt do
  def paint(filler, point \\ {0, 0}) do
    Pretty.Canvas.from_points(filler, [point])
  end
end
