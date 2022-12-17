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
  Returns a pretty canvas with padding added to the given `canvas`.

  ## Options

    * `top` - spaces to add to the top of the canvas.
    * `right` - spaces to add to the right of the canvas.
    * `bottom` - spaces to add to the bottom of the canvas
    * `left` - spaces to add to the left of the canvas.
  """
  @spec pad(Pretty.Canvas.t(), Keyword.t()) :: Pretty.Canvas.t()
  def pad(canvas, options \\ []) do
    Pretty.Canvas.pad(canvas, options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given canvas `over` overlayed on top of the
  given canvas `under`.
  """
  @spec overlay(Pretty.Canvas.t(), Petty.Canvas.t()) :: Pretty.Canvas.t()
  def overlay(under, over) do
    Pretty.Canvas.overlay(under, over)
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in the given `headers` and `rows`
  layed out in a table.
  """
  @spec table([term], [[term]], Keyword.t()) :: Pretty.Canvas.t()
  def table(headers, rows, options \\ []) do
    headers = Pretty.From.list(headers)
    rows = Pretty.From.matrix(rows)
    Pretty.Compose.table(headers, rows, options)
  end
end
