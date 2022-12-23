defmodule Pretty.Components.Bracket do
  alias Pretty.Canvas
  alias Pretty.Symbols

  alias Pretty.Components.Line
  alias Pretty.Components.DotAt

  def paint(top, bottom, options \\ []) do
    t = Keyword.get(options, :symbols, Symbols.box())

    side = Keyword.get(options, :side, :left)
    curly? = Keyword.get(options, :curly, false)

    bracket =
      case side do
        :left ->
          [
            Line.paint(Map.get(t, :vertical, "?"), top, bottom),
            DotAt.paint(Map.get(t, :down_and_right, "?"), top),
            DotAt.paint(Map.get(t, :up_and_right, "?"), bottom)
          ]

        :right ->
          [
            Line.paint(Map.get(t, :vertical, "?"), top, bottom),
            DotAt.paint(Map.get(t, :down_and_left, "?"), top),
            DotAt.paint(Map.get(t, :up_and_left, "?"), bottom)
          ]
      end
      |> Canvas.overlay()

    curly =
      if curly? do
        {x0, y0} = top
        {_, y1} = bottom

        mid = div(y0 + y1, 2)

        symbol =
          if side == :left,
            do: Map.get(t, :vertical_and_left, "?"),
            else: Map.get(t, :vertical_and_right, "?")

        DotAt.paint(symbol, {x0, mid})
      else
        Canvas.empty()
      end

    Canvas.overlay([bracket, curly])
  end
end
