defmodule Pretty.Layout.Placement do
  @type grid_item :: %{
          id: term(),
          row: pos_integer | nil,
          column: pos_integer | nil,
          row_span: pos_integer,
          column_span: pos_integer
        }

  @doc ~S"""
  Takes a list of grid items and place them in a grid by setting their row and column values.

  ## Options

  * `:limit` - The maximum number of cells in the flow direction. 
    (i.e the number of columns if `:flow` is `:row` or the number of rows if `:flow` is `:column`)
  * `:flow` - The direction in which items are placed. Defaults to `:row`.
  * `:empty_id` - The id of the empty items. Defaults to `:__empty`.
  """
  @spec place_items([grid_item], Keyword.t()) :: [grid_item]
  def place_items(items, options \\ []) do
    options = default_options(options)

    case options[:flow] do
      :row -> place_items_flow_row(items, options[:limit], options[:empty_id])
      :column -> place_items_flow_column(items, options[:limit], options[:empty_id])
    end
  end

  @doc ~S"""
  Returns a keyword list of options for the placement algorithm.
  """
  @spec default_options(Keyword.t()) :: Keyword.t()
  def default_options(options \\ []) do
    Keyword.merge(
      [
        flow: :row,
        limit: 1,
        empty_id: :__empty
      ],
      options
    )
  end

  #
  # FLOW ROW
  #

  #
  # if given an list of items, add empty items to fill the grid.
  #
  #
  @spec place_items_flow_row([grid_item], pos_integer, term()) :: [grid_item]
  defp place_items_flow_row([], column_count, empty_id) do
    items =
      List.duplicate(
        %{id: empty_id, column: nil, row: nil, row_span: 1, column_span: 1},
        column_count
      )

    place_items_flow_row(items, column_count, empty_id)
  end

  #
  # place the given items.
  #
  @spec place_items_flow_row([grid_item], pos_integer, term()) :: [grid_item]
  defp place_items_flow_row(items, column_count, empty_id) do
    # item with the greatest column span must fit in the grid, add column_count if necessary.
    column_count = max(column_count, items |> Enum.map(& &1.column_span) |> Enum.max())
    # run helper
    place_items_flow_row(items, [], 0, 0, MapSet.new(), column_count, empty_id)
  end

  #
  # no more items to place, return the placed items.
  #
  defp place_items_flow_row(
         [],
         placed_items,
         _row,
         col,
         _occupied_cells,
         column_count,
         _empty_id
       )
       when col >= column_count do
    # done!
    placed_items
  end

  #
  # empty cells but no items to place, add empty items to fill the grid.
  #
  # note: there can still be `non-filled` cells in the grid, since the grid is sparse.
  # `empty` cells are added to give the grid a `rectangular` shape.
  #
  defp place_items_flow_row(
         [],
         placed_items,
         row,
         col,
         occupied_cells,
         column_count,
         empty_id
       )
       when col < column_count do
    # fill the rest of the row with empty items
    items =
      List.duplicate(
        %{id: empty_id, column: nil, row: nil, row_span: 1, column_span: 1},
        column_count - col
      )

    place_items_flow_row(
      items,
      placed_items,
      row,
      col,
      occupied_cells,
      column_count,
      empty_id
    )
  end

  #
  # place the next item.
  #
  defp place_items_flow_row(
         [item | items_rest] = items,
         placed_items,
         # starts at 0
         row,
         # starts at 0
         col,
         occupied_cells,
         column_count,
         empty_id
       ) do
    # next row, if needed
    if col >= column_count do
      place_items_flow_row(
        items,
        placed_items,
        row + 1,
        0,
        occupied_cells,
        column_count,
        empty_id
      )
    else
      # if the item does not fit the remaining space in the row, try next row.
      if item.column_span > column_count - col do
        place_items_flow_row(
          items,
          placed_items,
          row + 1,
          0,
          occupied_cells,
          column_count,
          empty_id
        )
      else
        # find the cells that the item occupies.
        item_cells =
          MapSet.new(
            for rd <- 0..(item.row_span - 1),
                cd <- 0..(item.column_span - 1),
                do: {row + rd, col + cd}
          )

        # does the item overlap with any occupied cells?
        overlap? = !MapSet.disjoint?(occupied_cells, item_cells)

        # if there is overlap, try next column.
        if overlap? do
          place_items_flow_row(
            items,
            placed_items,
            row,
            col + 1,
            occupied_cells,
            column_count,
            empty_id
          )
        else
          # place the item in the grid.
          item = %{item | row: row, column: col}
          occupied_cells = MapSet.union(occupied_cells, item_cells)

          place_items_flow_row(
            items_rest,
            [item | placed_items],
            row,
            col + 1,
            occupied_cells,
            column_count,
            empty_id
          )
        end
      end
    end
  end

  #
  # FLOW COLUMN
  #

  #
  # if given an list of items, add empty items to fill the grid.
  #
  defp place_items_flow_column([], row_count, empty_id) do
    items =
      List.duplicate(
        %{id: empty_id, column: nil, row: nil, row_span: 1, column_span: 1},
        row_count
      )

    place_items_flow_column(items, row_count, empty_id)
  end

  #
  # place the given items.
  #
  defp place_items_flow_column(items, row_count, empty_id) do
    # item with the greatest row span must fit in the grid, increase row_count if necessary.
    row_count = max(row_count, items |> Enum.map(& &1.row_span) |> Enum.max())
    place_items_flow_column(items, [], 0, 0, MapSet.new(), row_count, empty_id)
  end

  #
  # no more items to place, return the placed items
  #
  defp place_items_flow_column(
         [],
         placed_items,
         row,
         _col,
         _occupied_cells,
         row_count,
         _empty_id
       )
       when row >= row_count do
    # done!
    placed_items
  end

  #
  # empty cells but no items to place, add empty items to fill the grid
  #
  # note: there can still be `non-filled` cells in the grid, since the grid is sparse.
  # `empty` cells are added to give the grid a `rectangular` shape.
  #
  defp place_items_flow_column(
         [],
         placed_items,
         row,
         col,
         occupied_cells,
         row_count,
         empty_id
       )
       when row < row_count do
    # fill the rest of the row with empty items
    items =
      List.duplicate(
        %{id: empty_id, column: nil, row: nil, row_span: 1, column_span: 1},
        row_count - row
      )

    place_items_flow_column(
      items,
      placed_items,
      row,
      col,
      occupied_cells,
      row_count,
      empty_id
    )
  end

  #
  # place the next item
  #
  defp place_items_flow_column(
         [item | items_rest] = items,
         placed_items,
         # starts at 0
         row,
         # starts at 0
         col,
         occupied_cells,
         row_count,
         empty_id
       ) do
    # next row, if needed
    if row >= row_count do
      place_items_flow_column(
        items,
        placed_items,
        0,
        col + 1,
        occupied_cells,
        row_count,
        empty_id
      )
    else
      # if the item does not fit the remaining space in the column, try next column.
      if item.row_span > row_count - row do
        place_items_flow_column(
          items,
          placed_items,
          0,
          col + 1,
          occupied_cells,
          row_count,
          empty_id
        )
      else
        # find the cells that the item occupies.
        item_cells =
          MapSet.new(
            for rd <- 0..(item.row_span - 1),
                cd <- 0..(item.column_span - 1),
                do: {row + rd, col + cd}
          )

        # does the item overlap with any occupied cells?
        overlap? = !MapSet.disjoint?(occupied_cells, item_cells)

        # if there is overlap, try next column.
        if overlap? do
          place_items_flow_column(
            items,
            placed_items,
            row + 1,
            col,
            occupied_cells,
            row_count,
            empty_id
          )
        else
          # place the item in the grid.
          item = %{item | row: row, column: col}
          occupied_cells = MapSet.union(occupied_cells, item_cells)

          place_items_flow_column(
            items_rest,
            [item | placed_items],
            row + 1,
            col,
            occupied_cells,
            row_count,
            empty_id
          )
        end
      end
    end
  end
end
