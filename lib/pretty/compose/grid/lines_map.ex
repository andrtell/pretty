defmodule Pretty.Compose.Grid.LinesMap do
  @type line :: {{integer, integer}, {integer, integer}}
  @type point :: {integer, integer}

  @type t :: %{
          horizontals: [line],
          verticals: [line],
          intersects: %{
            top: [point],
            bottom: [point],
            left: [point],
            right: [point],
            cross_up: [point],
            cross_down: [point],
            cross_left: [point],
            cross_right: [point],
            cross: [point]
          },
          corners: %{
            top_left: point,
            top_right: point,
            bottom_left: point,
            bottom_right: point
          }
        }
end
