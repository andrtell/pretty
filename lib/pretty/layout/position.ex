defmodule Pretty.Layout.Position do
  @moduledoc false

  @type positioned_item :: %{
          row: pos_integer,
          column: pos_integer,
          x_start: pos_integer | nil,
          x_end: pos_integer | nil,
          y_start: pos_integer | nil,
          y_end: pos_integer | nil
        }

  @type row_offsets :: map()
  @type column_offsets :: map()

  @type point :: {pos_integer, pos_integer}

  @doc ~S"""
  Give the given `items` absolute positions (x, y).

  ## Arguments

    * `items` - a list of items to place in the grid
    * `row_offsets` - a map of row offsets
    * `column_offsets` - a map of column offsets
  """
  @spec position_items([positioned_item], row_offsets(), column_offsets()) ::
          {[positioned_item], point()}
  def position_items(items, row_offsets, column_offsets) do
    Enum.map_reduce(items, {0, 0}, fn item, {x_max, y_max} ->
      {x_start, x_end} = Map.get(column_offsets, item.column)

      x_start = x_start
      x_end = x_end

      {y_start, y_end} = Map.get(row_offsets, item.row)

      y_start = y_start
      y_end = y_end

      item = %{
        item
        | x_start: x_start,
          x_end: x_end,
          y_start: y_start,
          y_end: y_end
      }

      x_max = max(x_end, x_max)
      y_max = max(y_end, y_max)

      {item, {x_max, y_max}}
    end)
  end
end
