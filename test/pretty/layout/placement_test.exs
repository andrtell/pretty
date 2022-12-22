defmodule Pretty.Layout.PlacementTest do
  use ExUnit.Case
  doctest Pretty.Layout.Placement

  alias Pretty.Layout.Placement

  setup do
    item1 = %{id: 1, row_span: 1, column_span: 1, row: nil, column: nil}
    item2 = %{id: 2, row_span: 1, column_span: 1, row: nil, column: nil}
    item3 = %{id: 3, row_span: 1, column_span: 1, row: nil, column: nil}
    item4 = %{id: 4, row_span: 1, column_span: 1, row: nil, column: nil}
    empty_item = %{id: :__empty, row_span: 1, column_span: 1, row: nil, column: nil}
    {:ok, item1: item1, item2: item2, item3: item3, item4: item4, empty_item: empty_item}
  end

  test "works for 1 item", context do
    item1 = context[:item1]

    {items, row_count, column_count} = Placement.place_items([item1], :row, 1)

    assert items == [%{item1 | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 1

    {items, row_count, column_count} = Placement.place_items([item1], :row, 1)

    assert items == [%{item1 | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 1

    {items, row_count, column_count} = Placement.place_items([item1], :column, 1)

    assert items == [%{item1 | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 1
  end

  test "adds 1 empty item when given empty list", context do
    empty_item = context[:empty_item]

    # limit defaults to 1, maybe change this.
    {items, row_count, column_count} = Placement.place_items([], :row, 1)

    assert items == [%{empty_item | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 1
  end

  test "adds `limit` empty items to empty list", context do
    empty_item = context[:empty_item]

    {items, row_count, column_count} = Placement.place_items([], :row, 2, empty_id: :__empty)

    assert items == [%{empty_item | row: 0, column: 1}, %{empty_item | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 2

    {items, row_count, column_count} = Placement.place_items([], :column, 2, empty_id: :__empty)

    assert items == [%{empty_item | row: 1, column: 0}, %{empty_item | row: 0, column: 0}]
    assert row_count == 2
    assert column_count == 1
  end

  test "add empty items when there are empty cells", context do
    item1 = context[:item1]
    empty_item = context[:empty_item]

    {items, row_count, column_count} = Placement.place_items([item1], :row, 2, empty_id: :__empty)

    assert items == [%{empty_item | row: 0, column: 1}, %{item1 | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 2

    {items, row_count, column_count} =
      Placement.place_items([item1], :column, 2, empty_id: :__empty)

    assert items == [%{empty_item | row: 1, column: 0}, %{item1 | row: 0, column: 0}]
    assert row_count == 2
    assert column_count == 1
  end

  test "places 2 items in rows", context do
    item1 = context[:item1]
    item2 = context[:item2]

    {items, row_count, column_count} =
      Placement.place_items([item1, item2], :row, 2, empty_id: :__empty)

    assert items == [%{item2 | row: 0, column: 1}, %{item1 | row: 0, column: 0}]
    assert row_count == 1
    assert column_count == 2
  end

  test "places 2 items in columns", context do
    item1 = context[:item1]
    item2 = context[:item2]

    {items, row_count, column_count} =
      Placement.place_items([item1, item2], :column, 2, empty_id: :__empty)

    assert items == [%{item2 | row: 1, column: 0}, %{item1 | row: 0, column: 0}]
    assert row_count == 2
    assert column_count == 1
  end

  test "places 3 items in rows, plus 1 empty", context do
    item1 = context[:item1]
    item2 = context[:item2]
    item3 = context[:item3]
    empty_item = context[:empty_item]

    {items, row_count, column_count} =
      Placement.place_items([item1, item2, item3], :row, 2, empty_id: :__empty)

    assert items == [
             %{empty_item | row: 1, column: 1},
             %{item3 | row: 1, column: 0},
             %{item2 | row: 0, column: 1},
             %{item1 | row: 0, column: 0}
           ]

    assert row_count == 2
    assert column_count == 2
  end

  test "places 3 items in columns, plus 1 empty", context do
    item1 = context[:item1]
    item2 = context[:item2]
    item3 = context[:item3]
    empty_item = context[:empty_item]

    {items, row_count, column_count} =
      Placement.place_items([item1, item2, item3], :column, 2, empty_id: :__empty)

    assert items == [
             %{empty_item | row: 1, column: 1},
             %{item3 | row: 0, column: 1},
             %{item2 | row: 1, column: 0},
             %{item1 | row: 0, column: 0}
           ]

    assert row_count == 2
    assert column_count == 2
  end

  test "places 4 items in rows", context do
    item1 = context[:item1]
    item2 = context[:item2]
    item3 = context[:item3]
    item4 = context[:item4]

    {items, row_count, column_count} =
      Placement.place_items([item1, item2, item3, item4], :row, 2, empty_id: :__empty)

    assert items == [
             %{item4 | row: 1, column: 1},
             %{item3 | row: 1, column: 0},
             %{item2 | row: 0, column: 1},
             %{item1 | row: 0, column: 0}
           ]

    assert row_count == 2
    assert column_count == 2
  end

  test "places 4 items in columns", context do
    item1 = context[:item1]
    item2 = context[:item2]
    item3 = context[:item3]
    item4 = context[:item4]

    {items, row_count, column_count} =
      Placement.place_items(
        [item1, item2, item3, item4],
        :column,
        2,
        empty_id: :__empty
      )

    assert items == [
             %{item4 | row: 1, column: 1},
             %{item3 | row: 0, column: 1},
             %{item2 | row: 1, column: 0},
             %{item1 | row: 0, column: 0}
           ]

    assert row_count == 2
    assert column_count == 2
  end

  test "default options" do
    options = Placement.default_options(empty_id: 99)
    assert Keyword.get(options, :empty_id) == 99
  end
end
