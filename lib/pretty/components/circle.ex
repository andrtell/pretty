defmodule Pretty.Components.Circle do
  alias Pretty.Components.Dots

  def paint(filler, r, options \\ []) do
    solid? = Keyword.get(options, :solid?, false)

    if solid? do
      Dots.paint(filler, Pretty.Plot.circle_solid(r))
      |> Pretty.Canvas.translate(r, r)
    else
      Dots.paint(filler, Pretty.Plot.circle(r))
      |> Pretty.Canvas.translate(r, r)
    end
  end
end
