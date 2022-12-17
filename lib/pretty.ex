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
  Returns a pretty canvas with the given items in `list` layed out in a grid.
  """
  @spec grid([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid(list, options \\ []) do
    Pretty.From.list(list) |> Pretty.Compose.grid(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `list` layed out in a grid 
  but without grid lines.
  """
  @spec grid_layout([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid_layout(list, options \\ []) do
    Pretty.From.list(list) |> Pretty.Compose.grid_layout(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `matrix` layed out in a 
  matrix-grid.
  """
  @spec matrix([[term]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix(matrix, options \\ []) do
    Pretty.From.matrix(matrix) |> Pretty.Compose.matrix(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the items in the given `matrix` layed out in a 
  matrix-grid but without the grid lines.
  """
  @spec matrix_layout([[term]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix_layout(matrix, options \\ []) do
    Pretty.From.matrix(matrix) |> Pretty.Compose.matrix_layout(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given `canvas` positioned relative to it
  self.

  ## Options

    * `top` - The top position of the canvas. Defaults to 0.
    * `left` - The left position of the canvas. Defaults to 0.
  """
  @spec relative(Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def relative(canvas, options \\ []) do
    dx = Keyword.get(options, :left, 0)
    dy = Keyword.get(options, :top, 0)
    Pretty.Canvas.relative(canvas, dx, dy)
  end

  @doc ~S"""
  Returns a pretty canvas with the given canvas `over` overlayed on top of the
  given canvas `under`.
  """
  @spec overlay(Pretty.Canvas.t(), Petty.Canvas.t()) :: Pretty.Canvas.t()
  def overlay(under, over) do
    Pretty.Canvas.overlay(under, over)
  end

end
