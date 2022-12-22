defmodule Pretty.Grid.Placement do
  @moduledoc false
  alias Pretty.Types, as: T
  alias Pretty.Grid.Item

  @type direction :: :row | :column

  @doc ~S"""
  Sets the row and column of each item in the given `items` list.

  Returns a list of items with the row and column set, and the resulting number 
  of rows and columns.

  ## Arguments

    * `items` - A list of items to place in the grid.
    * `direction` - Direction of item placement. one of `:row` or `:column`.
    * `limit` - The max number of cells in the direction direction. 

      :row         :column
    ╭───┬───╮     ╭───┬───╮  ┐
    │ 1 │ 2 │     │ 1 │ 3 │  │
    ├───┼───┤     ├───┼───┤  ┤ limit
    │ 3 │   │     │ 2 │   │  │
    ╰───┴───╯     ╰───┴───╯  ┘

    └───┴───┘
      limit

  ## Options

    * `empty_id` - The id of the empty items. Defaults to `:__empty`.
  """
  @spec place_items([Item.t()], direction(), T.count(), Keyword.t()) ::
          {[Item.t()], T.count(), T.count()}
  def place_items(items, direction, limit, options \\ []) do
    options = default_options(options)

    case direction do
      :row -> place_items_direction_row(items, limit, options[:empty_id])
      :column -> place_items_direction_column(items, limit, options[:empty_id])
    end
  end

  @doc ~S"""
  Returns a keyword list of default options.
  """
  @spec default_options(Keyword.t()) :: Keyword.t()
  def default_options(options \\ []) do
    Keyword.merge(
      [
        empty_id: :__empty
      ],
      options
    )
  end

  #
  # if given an list of items, add empty items to fill the grid.
  #
  @spec place_items_direction_row([Item.t()], T.count(), term()) ::
          {[Item.t()], T.count(), T.count()}
  defp place_items_direction_row([], column_count, empty_id) do
    items =
      List.duplicate(
        Item.empty(empty_id),
        column_count
      )

    place_items_direction_row(items, column_count, empty_id)
  end

  #
  # place the given items.
  #
  @spec place_items_direction_row([Item.t()], T.count(), term()) ::
          {[Item.t()], T.count(), T.count()}
  defp place_items_direction_row(items, column_count, empty_id) do
    # item with the greatest column span must fit in the grid, add column_count if necessary.
    column_count = max(column_count, items |> Enum.map(& &1.column_span) |> Enum.max())
    # run helper
    {items, row_count} =
      place_items_direction_row(items, [], 0, 0, MapSet.new(), column_count, empty_id)

    {items, row_count, column_count}
  end

  #
  # no more items to place, return the placed items.
  #
  @spec place_items_direction_row(
          [Item.t()],
          [Item.t()],
          T.index(),
          T.index(),
          MapSet.t(),
          T.count(),
          term()
        ) :: {[Item.t()], pos_integer}
  defp place_items_direction_row(
         [],
         placed_items,
         row,
         col,
         _occupied_cells,
         column_count,
         _empty_id
       )
       when col >= column_count do
    # done!
    {placed_items, row + 1}
  end

  #
  # empty cells but no items to place, add empty items to fill the grid.
  #
  # note: there can still be `non-filled` cells in the grid, since the grid is sparse.
  # `empty` cells are added to give the grid a `rectangular` shape.
  #
  defp place_items_direction_row(
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
        Item.empty(empty_id),
        column_count - col
      )

    place_items_direction_row(
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
  defp place_items_direction_row(
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
      place_items_direction_row(
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
        place_items_direction_row(
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
          place_items_direction_row(
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

          place_items_direction_row(
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
  # if given an list of items, add empty items to fill the grid.
  #
  @spec place_items_direction_row([Item.t()], T.count(), term()) ::
          {[Item.t()], T.count(), T.count()}
  defp place_items_direction_column([], row_count, empty_id) do
    items =
      List.duplicate(
        Item.empty(empty_id),
        row_count
      )

    place_items_direction_column(items, row_count, empty_id)
  end

  #
  # place the given items.
  #
  defp place_items_direction_column(items, row_count, empty_id) do
    # item with the greatest row span must fit in the grid, increase row_count if necessary.
    row_count = max(row_count, items |> Enum.map(& &1.row_span) |> Enum.max())

    {items, column_count} =
      place_items_direction_column(items, [], 0, 0, MapSet.new(), row_count, empty_id)

    {items, row_count, column_count}
  end

  #
  # no more items to place, return the placed items
  #
  @spec place_items_direction_column(
          [Item.t()],
          [Item.t()],
          T.index(),
          T.index(),
          MapSet.t(),
          T.count(),
          term()
        ) :: {[Item.t()], pos_integer}
  defp place_items_direction_column(
         [],
         placed_items,
         row,
         col,
         _occupied_cells,
         row_count,
         _empty_id
       )
       when row >= row_count do
    # done!
    {placed_items, col + 1}
  end

  #
  # empty cells but no items to place, add empty items to fill the grid
  #
  # note: there can still be `non-filled` cells in the grid, since the grid is sparse.
  # `empty` cells are added to give the grid a `rectangular` shape.
  #
  defp place_items_direction_column(
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
        Item.empty(empty_id),
        row_count - row
      )

    place_items_direction_column(
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
  defp place_items_direction_column(
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
      place_items_direction_column(
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
        place_items_direction_column(
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

        # if there is overlap, try next row.
        if overlap? do
          place_items_direction_column(
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

          place_items_direction_column(
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
