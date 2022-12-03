defmodule Pretty.Components.GridLines do
  alias Pretty.Canvas
  alias Pretty.Symbols

  alias Pretty.Components.Line
  alias Pretty.Components.DotAt

  def paint(
        %{
          horizontal_lines: horizontals,
          vertical_lines: verticals,
          intersects: intersects
        } = _line_map,
        options \\ []
      ) do
    t = Keyword.get(options, :symbols, Symbols.box())

    [
      for({p1, p2} <- verticals, do: Line.paint(Map.get(t, :vertical, "?"), p1, p2)),
      for({p1, p2} <- horizontals, do: Line.paint(Map.get(t, :horizontal, "?"), p1, p2)),
      for({p, v} <- intersects, do: DotAt.paint(Map.get(t, v, "?"), p))
    ]
    |> List.flatten()
    |> Canvas.overlay()
  end
end
