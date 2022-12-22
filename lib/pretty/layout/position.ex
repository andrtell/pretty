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

  @type top_left_item :: {pos_integer, pos_integer}
  @type bottom_right_item :: {pos_integer, pos_integer}

  @type width :: pos_integer
  @type height :: pos_integer

  @doc ~S"""
  Give the given `items` absolute positions (x, y).

  ## Arguments

    * `items` - a list of items to place in the grid
    * `row_offsets` - a map of row offsets
    * `column_offsets` - a map of column offsets
  """
  @spec position_items([positioned_item], row_offsets(), column_offsets(), Keyword.t()) ::
          {[positioned_item], top_left_item(), bottom_right_item(), width(), height()}
  def position_items(items, row_offsets, column_offsets, options \\ []) do
    top = Keyword.get(options, :top, 0)
    bottom = Keyword.get(options, :bottom, 0)
    left = Keyword.get(options, :left, 0)
    right = Keyword.get(options, :right, 0)

    {items, {x_max, y_max}} =
      Enum.map_reduce(items, {0, 0}, fn item, {x_max, y_max} ->
        {x_start, x_end} = Map.get(column_offsets, item.column)

        x_start = x_start + left
        x_end = x_end + left

        {y_start, y_end} = Map.get(row_offsets, item.row)

        y_start = y_start + top
        y_end = y_end + top

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

    {items, {left, top}, {x_max, y_max}, x_max + right, y_max + bottom}
  end
end
