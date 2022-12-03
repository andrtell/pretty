defmodule Pretty.Components.GridLayout do
  def paint(canvases, options \\ []) do
    Pretty.Grid.paint(canvases, nil, options)
  end
end
