defmodule Pretty.Components.Grid do
  alias Pretty.Components.GridLines

  def paint(canvases, options \\ []) do
    Pretty.Grid.paint(canvases, &GridLines.paint/2, options)
  end
end
