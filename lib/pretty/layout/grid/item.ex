defmodule Pretty.Layout.Grid.Item do
  alias Pretty.Canvas
  alias Pretty.Canvas.Box

  defstruct id: nil,
            x_start: nil,
            x_end: nil,
            y_start: nil,
            y_end: nil,
            width: nil,
            height: nil,
            column_span: 1,
            row_span: 1,
            column_start: nil,
            column_end: nil,
            row_start: nil,
            row_end: nil

  @type t :: %__MODULE__{
          id: integer | nil,
          x_start: non_neg_integer() | nil,
          x_end: non_neg_integer() | nil,
          y_start: non_neg_integer() | nil,
          y_end: non_neg_integer() | nil,
          width: pos_integer | nil,
          height: pos_integer | nil,
          column_span: pos_integer | nil,
          row_span: pos_integer | nil,
          row_start: pos_integer | nil,
          row_end: pos_integer | nil,
          column_start: pos_integer | nil,
          column_end: pos_integer | nil
        }

  @doc ~S"""
  Creates a new grid item from a canvas.
  """
  @spec from_canvas(Pretty.Canvas.t(), Keyword.t()) :: t()
  def from_canvas(canvas, grid) do

    %__MODULE__{
      id: Canvas.get_meta(canvas, :id, nil),
      row_span: Canvas.get_meta(canvas, :row_span, 1),
      column_span: Canvas.get_meta(canvas, :column_span, 1),
      width: (Canvas.box(canvas) |> Box.width()) + grid.pad_items_left + grid.pad_items_right,
      height: (Canvas.box(canvas) |> Box.height()) + grid.pad_items_top + grid.pad_items_bottom,
      # string: Canvas.to_string(canvas)
    }
  end

  @doc ~S"""
  Places the given `item` at the given `row` and `column`.
  """
  def place_item_at(item, {row, column}) do
    %__MODULE__{
      item
      | row_start: row,
        row_end: row + item.row_span,
        column_start: column,
        column_end: column + item.column_span
    }
  end

  def flip(item) do
    %__MODULE__{
      item
      | row_span: item.column_span,
        column_span: item.row_span
    }
  end

  @doc ~S"""
  Returns the list of points the given `item` occupies.

  The `cursor` is a tuple of `{row, column}`.

  ## Examples

      iex> item = %Pretty.Layout.Grid.Item{column_span: 2}
      iex> Pretty.Layout.Grid.Item.area_at(item, {0, 0})
      [{0, 0}, {0, 1}]
  """
  def area_at(item, {row, column} = _cursor) do
    for row_delta <- 0..(item.row_span - 1),
        column_delta <- 0..(item.column_span - 1) do
      {row + row_delta, column + column_delta}
    end
  end

  @doc ~S"""
  Returns true if the item fits in within the remaining columns.

  The `cursor` is a tuple of `{row, column}`.

  ## Examples

      iex> item = %Pretty.Layout.Grid.Item{column_span: 2}
      iex> Pretty.Layout.Grid.Item.fits_row?(item, {0, 0}, 2)
      true
      iex> Pretty.Layout.Grid.Item.fits_row?(item, {0, 1}, 2)
      false
  """
  @spec fits_row?(t(), {pos_integer(), pos_integer()}, pos_integer()) :: boolean()
  def fits_row?(item, {_, column} = _cursor, column_count) do
    column + item.column_span <= column_count
  end

  @spec fits_column?(t(), {pos_integer(), pos_integer()}, pos_integer()) :: boolean()
  def fits_column?(item, {row, _} = _cursor, row_count) do
    row + item.row_span <= row_count
  end

  @doc ~S"""
  Returns true if the given `item` at `cursor` overlaps with any of the 
  positions in the given `occupied`.

  The `cursor` is the current position in the grid `{row, column}`.
  The `occupied` is a mapset of `{row, column}`.

  ## Examples

      iex> item = %Pretty.Layout.Grid.Item{column_span: 2}
      iex> occupied = MapSet.new([{0, 0}, {0, 1}])
      iex> Pretty.Layout.Grid.Item.overlaps_at?(item, {0, 0}, occupied)
      true
      iex> Pretty.Layout.Grid.Item.overlaps_at?(item, {0, 2}, occupied)
      false
  """
  def overlaps_at?(item, cursor, occupied) do
    area = area_at(item, cursor)

    Enum.any?(area, fn position ->
      MapSet.member?(occupied, position)
    end)
  end
end
