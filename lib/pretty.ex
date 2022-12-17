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
  Returns a pretty canvas with the items layed out in a grid.
  """
  @spec grid([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid(list, options \\ []) do
    Pretty.From.list(list) |> Pretty.Compose.grid(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the items layed out in a grid but without the grid lines.
  """
  @spec grid_layout([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid_layout(list, options \\ []) do
    Pretty.From.list(list) |> Pretty.Compose.grid_layout(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the items layout out in a matrix grid.
  """
  @spec matrix([[term]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix(matrix, options \\ []) do
    Pretty.From.matrix(matrix) |> Pretty.Compose.matrix(options)
  end
end
