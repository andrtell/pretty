defmodule Pretty do
  @moduledoc """
  Pretty printing Elixir terms and more.
  """

  @doc ~S"""
  Converts `term` to a pretty canvas.
  """
  @spec from(term) :: Pretty.Canvas.t()
  def from(term) do
    Pretty.From.term(term)
  end

  @doc ~S"""
  Returns a pretty canvas with a grid.
  """
  @spec grid([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid(list, options \\ []) do
    Pretty.From.list(list) |> Pretty.Compose.grid(options)
  end
end
