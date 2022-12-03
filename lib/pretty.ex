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
    options = grid_options(options)
    options = Keyword.merge([pad_items: [left: 1, right: 1]], options)
    Pretty.From.list(list) |> Pretty.Components.Grid.paint(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `list` layed out in a grid 
  but without grid lines.
  """
  @spec grid_layout([term], Keyword.t()) :: Pretty.Canvas.t()
  def grid_layout(list, options \\ []) do
    options = grid_options(options)
    options = Keyword.merge([pad_items: [left: 0, right: 0]], options)
    Pretty.From.list(list) |> Pretty.Components.GridLayout.paint(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the given items in `matrix` layed out in a 
  matrix-grid.
  """
  @spec matrix([[term]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix(matrix, options \\ []) do
    options = Keyword.merge([pad_items: [left: 0, right: 0]], options)
    Pretty.From.matrix(matrix) |> Pretty.Components.Matrix.paint(options)
  end

  @doc ~S"""
  Returns a pretty canvas with the items in the given `matrix` layed out in a 
  matrix-grid but without the grid lines.
  """
  @spec matrix_layout([[term]], Keyword.t()) :: Pretty.Canvas.t()
  def matrix_layout(matrix, options \\ []) do
    Pretty.From.matrix(matrix) |> Pretty.Components.MatrixLayout.paint(options)
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

  def span(canvas, options \\ []) do
    rows = Keyword.get(options, :rows, 1)
    columns = Keyword.get(options, :columns, 1)

    canvas
    |> Pretty.Canvas.put_meta(:row_span, rows)
    |> Pretty.Canvas.put_meta(:column_span, columns)
  end

  @doc ~S"""
  Returns a pretty canvas with the given canvas `over` overlayed on top of the
  given canvas `under`.
  """
  @spec overlay(Pretty.Canvas.t(), Pretty.Canvas.t()) :: Pretty.Canvas.t()
  def overlay(under, over) do
    Pretty.Canvas.overlay(under, over)
  end

  #
  #
  #
  defp grid_options(options) do
    if Keyword.has_key?(options, :columns) do
      Keyword.merge(
        [
          direction: :row,
          limit: Keyword.get(options, :columns)
        ],
        options
      )
    else
      Keyword.merge(
        [
          direction: :column,
          limit: Keyword.get(options, :rows, 1)
        ],
        options
      )
    end
  end
end
