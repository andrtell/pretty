#
# Pretty.Canvas.Term
#

defprotocol Pretty.Canvas.Term do
  def to_canvas(value, opts \\ [])
end

defimpl Pretty.Canvas.Term, for: Pretty.Canvas do
  def to_canvas(canvas, _opts), do: canvas
end

defimpl Pretty.Canvas.Term, for: BitString do
  def to_canvas(str, _opts), do: Pretty.Canvas.from_string(str)
end

defimpl Pretty.Canvas.Term, for: Atom do
  def to_canvas(a, _opts),
    do: Pretty.Canvas.from_string(":" <> to_string(a))
end

defimpl Pretty.Canvas.Term, for: Integer do
  def to_canvas(integer, _opts),
    do: Pretty.Canvas.from_string(to_string(integer))
end

defimpl Pretty.Canvas.Term, for: Float do
  def to_canvas(float, _opts),
    do: Pretty.Canvas.from_string(to_string(float))
end

defimpl Pretty.Canvas.Term, for: Function do
  def to_canvas(_function, _opts),
    do: Pretty.Canvas.from_string("f()?")
end

defimpl Pretty.Canvas.Term, for: PID do
  def to_canvas(pid, _opts),
    do: Pretty.Canvas.from_string(to_string(:erlang.pid_to_list(pid)))
end

defimpl Pretty.Canvas.Term, for: Port do
  def to_canvas(port, _opts),
    do: Pretty.Canvas.from_string(to_string(:erlang.port_to_list(port)))
end

defimpl Pretty.Canvas.Term, for: Reference do
  def to_canvas(reference, _opts),
    do: Pretty.Canvas.from_string(to_string(:erlang.ref_to_list(reference)))
end

#
# Here be dragons: 
#
# Above this comment only Pretty.Canvas.from_string can be used.
#
# This is to avoid infinite recursion.
#

defimpl Pretty.Canvas.Term, for: List do
  def to_canvas(list, opts) do
    canvas_list = Pretty.From.list(list)
    Pretty.Components.PrettyList.paint(canvas_list, opts)
  end
end

defimpl Pretty.Canvas.Term, for: Tuple do
  def to_canvas(tuple, opts) do
    canvas_tuple = Pretty.From.tuple(tuple)
    Pretty.Components.PrettyTuple.paint(canvas_tuple, opts)
  end
end

defimpl Pretty.Canvas.Term, for: Map do
  def to_canvas(map, opts) do
    canvas_map = Pretty.From.map(map)
    Pretty.Components.PrettyMap.paint(canvas_map, opts)
  end
end

#
# String.Chars
#

defimpl String.Chars, for: Pretty.Canvas do
  def to_string(canvas) do
    Pretty.Canvas.to_string(canvas)
  end
end
