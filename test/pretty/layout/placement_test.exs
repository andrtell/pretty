defmodule Pretty.Layout.PlacementTest do
  use ExUnit.Case
  doctest Pretty.Layout.Placement

  alias Pretty.Layout.Placement

  test "places a single item" do
    items = [%{id: 1, row_span: 1, column_span: 1, row: nil, column: nil}]

    assert Placement.place_items(items) == [
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items(items, limit: 1) == [
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items(items, flow: :column) == [
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items(items, flow: :column, limit: 1) == [
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]
  end

  test "places empty items to fill every cell of the grid" do
    assert Placement.place_items([]) == [
             %{id: :__empty, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items([], limit: 2, empty_id: :__empty) == [
             %{id: :__empty, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: :__empty, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    items = [%{id: 1, row: nil, column: nil, row_span: 1, column_span: 1}]

    assert Placement.place_items(items, limit: 2, empty_id: :__empty) == [
             %{id: :__empty, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items([], limit: 2, flow: :column, empty_id: :__empty) == [
             %{id: :__empty, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: :__empty, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items(items, limit: 2, flow: :column, empty_id: :__empty) == [
             %{id: :__empty, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]
  end

  test "places items correctly" do

    items = [
      %{id: 1, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 2, row: nil, column: nil, row_span: 1, column_span: 1}
    ]

    assert Placement.place_items(items, limit: 2, flow: :row, empty_id: :__empty) == [
             %{id: 2, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    items = [
      %{id: 1, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 2, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 3, row: nil, column: nil, row_span: 1, column_span: 1}
    ]

    assert Placement.place_items(items, limit: 2, flow: :row, empty_id: :__empty) == [
             %{id: :__empty, row: 1, column: 1, row_span: 1, column_span: 1},
             %{id: 3, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: 2, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    assert Placement.place_items(items, limit: 2, flow: :column, empty_id: :__empty) == [
             %{id: :__empty, row: 1, column: 1, row_span: 1, column_span: 1},
             %{id: 3, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 2, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]

    items = [
      %{id: 1, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 2, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 3, row: nil, column: nil, row_span: 1, column_span: 1},
      %{id: 4, row: nil, column: nil, row_span: 1, column_span: 1}
    ]

    assert Placement.place_items(items, limit: 2, flow: :row, empty_id: :__empty) == [
             %{id: 4, row: 1, column: 1, row_span: 1, column_span: 1},
             %{id: 3, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: 2, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]
           
    assert Placement.place_items(items, limit: 2, flow: :column, empty_id: :__empty) == [
             %{id: 4, row: 1, column: 1, row_span: 1, column_span: 1},
             %{id: 3, row: 0, column: 1, row_span: 1, column_span: 1},
             %{id: 2, row: 1, column: 0, row_span: 1, column_span: 1},
             %{id: 1, row: 0, column: 0, row_span: 1, column_span: 1}
           ]
  end

  test "default options" do
    options = Placement.default_options(flow: :row)
    assert Keyword.get(options, :flow) == :row

    options = Placement.default_options(limit: 2)
    assert Keyword.get(options, :limit) == 2

    options = Placement.default_options(empty_id: 99)
    assert Keyword.get(options, :empty_id) == 99

    options = Placement.default_options(auto_flow: :column)
    assert Keyword.get(options, :auto_flow) == :column

    options = Placement.default_options()

    assert Keyword.get(options, :limit) == 1
    assert Keyword.get(options, :empty_id) == :__empty
    assert Keyword.get(options, :flow) == :row
  end
end
