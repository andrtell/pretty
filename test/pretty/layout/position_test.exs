defmodule Pretty.Layout.PositionTest do
  use ExUnit.Case
  doctest Pretty.Layout.Position

  alias Pretty.Layout.Position

  setup do
    item1 = %{
      id: 1,
      row: 0,
      column: 0,
      x_start: nil,
      x_end: nil,
      y_start: nil,
      y_end: nil
    }

    item2 = %{
      id: 1,
      row: 0,
      column: 0,
      x_start: nil,
      x_end: nil,
      y_start: nil,
      y_end: nil
    }

    {:ok, item1: item1, item2: item2}
  end

  test "works for 1 item", context do
    item1 = context[:item1]
    ret = Position.position_items([item1], %{0 => {0, 1}}, %{0 => {0, 1}})

    assert ret == {
             [%{item1 | x_start: 0, x_end: 1, y_start: 0, y_end: 1}],
             {1, 1}
           }
  end

  test "works for 2 items on 1 row", context do
    item1 = %{context[:item1] | row: 0, column: 0}
    item2 = %{context[:item2] | row: 0, column: 1}

    ret =
      Position.position_items(
        [item1, item2],
        %{0 => {0, 1}},
        %{0 => {0, 1}, 1 => {1, 2}}
      )

    assert ret == {
             [
               %{item1 | x_start: 0, x_end: 1, y_start: 0, y_end: 1},
               %{item2 | x_start: 1, x_end: 2, y_start: 0, y_end: 1}
             ],
             {2, 1}
           }
  end

  test "works for 2 items in 1 column", context do
    item1 = %{context[:item1] | row: 0, column: 0}
    item2 = %{context[:item2] | row: 1, column: 0}

    ret =
      Position.position_items(
        [item1, item2],
        %{0 => {0, 1}, 1 => {1, 2}},
        %{0 => {0, 1}}
      )

    assert ret == {
             [
               %{item1 | x_start: 0, x_end: 1, y_start: 0, y_end: 1},
               %{item2 | x_start: 0, x_end: 1, y_start: 1, y_end: 2}
             ],
             {1, 2}
           }
  end
end
