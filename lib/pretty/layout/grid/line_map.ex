defmodule Pretty.Layout.Grid.LineMap do
  defstruct [:horizontals, :verticals, :intersects, :corners]

  @type line :: {{integer, integer}, {integer, integer}}
  @type point :: {integer, integer}

  @type t :: %{
          horizontals: [line],
          verticals: [line],
          intersects: %{},
          corners: %{},
        }
end
