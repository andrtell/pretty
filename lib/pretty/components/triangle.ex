defmodule Pretty.Components.Triangle do
  alias Pretty.Components.Polygon

  def paint(filler, p1, p2, p3) do
    Polygon.paint(filler, [p1, p2, p3])
  end
end
