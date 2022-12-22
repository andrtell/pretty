defmodule Pretty.Layout.Sizing do
  @moduledoc false

  @type sized_item :: %{
          row: pos_integer,
          column: pos_integer,
          row_span: pos_integer,
          column_span: pos_integer,
          width: pos_integer,
          height: pos_integer
        }

  @type column_count :: pos_integer
  @type row_count :: pos_integer
  @type row_gap :: pos_integer
  @type column_gap :: pos_integer

  @type row_offsets :: map()
  @type column_offsets :: map()

  @doc ~S"""
  Sets the width and height of the given `items` to the height and width of the row
  and column they are in.

  ## Arguments

    * `items` - a list of items to place in the grid
    * `row_count` - the number of rows in the grid
    * `column_count` - the number of columns in the grid
    * `row_gap` - the gap between rows
    * `column_gap` - the gap between columns
  """
  @spec size_items([sized_item], row_count(), column_count(), row_gap(), column_gap()) :: [
          {sized_item, row_offsets(), column_offsets()}
        ]
  def size_items(items, row_count, column_count, row_gap, column_gap) do
    # find the height of each row
    row_heights = items_row_heights(items, row_count, row_gap)

    # get the width of each column
    column_widths = items_column_widths(items, column_count, column_gap)

    # set the new width and height of each item
    items =
      Enum.map(items, fn item ->
        width =
          if item.column_span == 1 do
            column_widths[item.column]
          else
            last_column = item.column_start + item.column_span - 1

            width =
              Enum.map(item.column..last_column, &Map.get(column_widths, &1))
              |> Enum.sum()

            width + (item.column_span - 1) * column_gap
          end

        height =
          if item.row_span == 1 do
            row_heights[item.row]
          else
            last_row = item.row_start + item.row_span - 1

            height =
              Enum.map(item.row..last_row, &Map.get(row_heights, &1))
              |> Enum.sum()

            height + (item.row_span - 1) * row_gap
          end

        %{item | width: width, height: height}
      end)

    {items, offsets(row_heights, row_gap), offsets(column_widths, column_gap)}
  end

  #
  # find the width of each column given a list of items.
  #
  def items_column_widths(items, column_count, column_gap) do
    # min column width is 1 
    column_widths = for column <- 0..(column_count - 1), do: {column, 1}, into: %{}

    {items_1, items_2} = Enum.split_with(items, fn item -> item.column_span == 1 end)

    # account for widths of items that span exactly 1 column.
    column_widths =
      Enum.reduce(items_1, column_widths, fn item, column_widths ->
        Map.update(column_widths, item.column, item.width, &max(&1, item.width))
      end)

    # account for widths of items that span 2 or more columns.
    Enum.reduce(items_2, column_widths, fn item, column_widths ->
      # current item last column
      last_column = item.column_start + item.column_span - 1

      # calculate the pre-update 2+ span width.
      span_width =
        Enum.map(item.column..last_column, &Map.get(column_widths, &1))
        |> Enum.sum()

      span_width = span_width + (item.column_span - 1) * column_gap

      # width difference
      difference = item.width - span_width

      # add 1 to each column width in turn until the difference is 0.
      if difference > 0 do
        Enum.reduce(0..(difference - 1), column_widths, fn i, column_widths ->
          Map.update(
            column_widths,
            item.column_start + rem(i, item.column_span),
            1,
            &(&1 + 1)
          )
        end)
      else
        column_widths
      end
    end)
  end

  #
  # find the height of each row given a list of items.
  #
  def items_row_heights(items, row_count, row_gap) do
    # default row height is 1
    row_heights = for row <- 0..(row_count - 1), do: {row, 1}, into: %{}

    {items_1, items_2} = Enum.split_with(items, fn item -> item.column_span == 1 end)

    # account for heights of items that span exactly 1 row.
    row_heights =
      Enum.reduce(items_1, row_heights, fn item, row_heights ->
        Map.update(row_heights, item.row, item.height, &max(&1, item.height))
      end)

    # account for heights of items that span 2 or more rows.
    Enum.reduce(items_2, row_heights, fn item, row_heights ->
      # current item last column
      last_row = item.row_start + item.row_span - 1

      # calculate the pre-update 2+ span height.
      span_height =
        Enum.map(item.row..last_row, &Map.get(row_heights, &1))
        |> Enum.sum()

      span_height = span_height + (item.row_span - 1) * row_gap

      # height difference
      difference = item.height - span_height

      if difference > 0 do
        Enum.reduce(0..(difference - 1), row_heights, fn i, row_heights ->
          Map.update(row_heights, item.row + rem(i, item.row_span), 1, &(&1 + 1))
        end)
      else
        row_heights
      end
    end)
  end

  #
  # Calulates the start and end position of each column or row.
  #
  # Note: the offset end is non-inclusive.
  #
  # Arguments
  #
  #   * `dimensions` - either `row_heights` or `column_widths`
  #   * `gap` - either `row_gap` or `column_gap`
  # 
  # ## Examples
  #
  #   iex> offsets(%{0 => 5, 1 => 5}, 2)
  #   %{0 => {0, 5}, 1 => {7, 12}}
  #
  defp offsets(dimensions, gap) do
    dimensions_list =
      Map.to_list(dimensions)
      |> Enum.sort()
      |> Enum.map(&elem(&1, 1))

    offsets_left =
      dimensions_list
      |> List.insert_at(0, 0)
      |> Enum.scan(-gap, &(&1 + &2 + gap))

    offsets_left
    |> Enum.zip(dimensions_list)
    |> Enum.map(fn {left, width} -> {left, left + width} end)
    |> Enum.with_index(fn x, i -> {i, x} end)
    |> Map.new()
  end
end
