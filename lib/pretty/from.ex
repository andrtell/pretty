defmodule Pretty.From do
  alias Pretty.Canvas

  @moduledoc false

  @doc ~S"""
  Returns a Pretty.Canvas given a `term` that implements Pretty.Canvas.Term.
  """
  @spec term(term()) :: Canvas.t()
  def term(term) do
    Canvas.Term.to_canvas(term)
  end

  @doc ~S"""
  Returns a list of canvases given a `list` of terms that implements Pretty.Canvas.Term.
  """
  @spec list([term()]) :: [Pretty.Canvas.t()]
  def list(list) do
    Enum.map(list, &term(&1))
  end

  @doc ~S"""
  Returns a tuple of canvases given a `tuple` of terms that implements Pretty.Canvas.Term.
  """
  @spec tuple(tuple()) :: tuple()
  def tuple(list) do
    List.to_tuple(list(Tuple.to_list(list)))
  end

  @doc ~S"""
  Returns a list of list of canvases given a `matrix` of list of lists of terms 
  that implements Pretty.Canvas.Term.
  """
  @spec matrix([[term()]]) :: [[Pretty.Canvas.t()]]
  def matrix(matrix) do
    Enum.map(matrix, fn row -> Enum.map(row, &term(&1)) end)
  end

  @doc ~S"""
  Returns a map with canvas keys and values given a `map` of keys and values that 
  implements Pretty.Canvas.Term.
  """
  @spec map(map()) :: %{
          required(Canvas.t()) => Canvas.t()
        }
  def map(map) do
    for {k, v} <- map,
        do: {
          term(k),
          term(v)
        },
        into: %{}
  end
end
