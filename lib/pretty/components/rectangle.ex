defmodule Pretty.Components.Rectangle do
  alias Pretty.Components.Polygon
  alias Pretty.Components.Dots

  def paint(filler, width, height, options \\ []) do
    solid? = Keyword.get(options, :solid?, false)

    if solid? do
      Dots.paint(filler, for(x <- 0..(width - 1), y <- 0..(height - 1), do: {x, y}))
    else
      Polygon.paint(
        filler,
        [{0, 0}, {width - 1, 0}, {width - 1, height - 1}, {0, height - 1}]
      )
    end
  end
end
