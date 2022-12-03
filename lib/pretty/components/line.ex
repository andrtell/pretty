defmodule Pretty.Components.Line do
  alias Pretty.Components.Dots

  def paint(filler, {x0, y0} = p1, {x1, y1} = p2) do
    cond do
      p1 == p2 -> Dots.paint(filler, [p1])
      y0 == y1 -> Dots.paint(filler, for(x <- x0..x1, do: {x, y0}))
      x0 == x1 -> Dots.paint(filler, for(y <- y0..y1, do: {x0, y}))
      true -> Dots.paint(filler, Pretty.Plot.line(p1, p2))
    end
  end
end
