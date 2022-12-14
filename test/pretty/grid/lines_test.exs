defmodule Pretty.Grid.LinesTest do
  use ExUnit.Case
  doctest Pretty.Grid.Lines

  setup do
    item1 = %{
      id: 1,
      row: 0,
      column: 0,
      row_span: 1,
      column_span: 1
    }

    item2 = %{
      id: 2,
      row: 0,
      column: 1,
      row_span: 1,
      column_span: 1
    }

    {:ok, item1: item1, item2: item2}
  end

  test "it works", context do
    item1 = context[:item1]

    row_gap_offsets = %{0 => {-1, 1}}
    column_gap_offsets = %{0 => {-1, 1}}

    result = Pretty.Grid.Lines.make_lines([item1], row_gap_offsets, column_gap_offsets)

    assert result == %{
             horizontal_lines: [{{-1, -1}, {1, -1}}, {{-1, 1}, {1, 1}}],
             vertical_lines: [{{-1, -1}, {-1, 1}}, {{1, -1}, {1, 1}}],
             intersects: %{
               {-1, -1} => :down_and_right,
               {-1, 1} => :up_and_right,
               {1, -1} => :down_and_left,
               {1, 1} => :up_and_left
             }
           }
  end

  test "row span 2", context do
    item1 = %{context[:item1] | row_span: 2}

    row_gap_offsets = %{0 => {-1, 1}, 1 => {1, 3}}
    column_gap_offsets = %{0 => {-1, 1}}

    result = Pretty.Grid.Lines.make_lines([item1], row_gap_offsets, column_gap_offsets)

    assert result == %{
             horizontal_lines: [{{-1, -1}, {1, -1}}, {{-1, 3}, {1, 3}}],
             vertical_lines: [{{-1, -1}, {-1, 3}}, {{1, -1}, {1, 3}}],
             intersects: %{
               {-1, -1} => :down_and_right,
               {-1, 1} => :vertical,
               {-1, 3} => :up_and_right,
               {1, -1} => :down_and_left,
               {1, 1} => :vertical,
               {1, 3} => :up_and_left
             }
           }
  end

  test "col span 2", context do
    item1 = %{context[:item1] | column_span: 2}

    row_gap_offsets = %{0 => {-1, 1}, 1 => {1, 3}}
    column_gap_offsets = %{0 => {-1, 1}, 1 => {1, 3}}

    result = Pretty.Grid.Lines.make_lines([item1], row_gap_offsets, column_gap_offsets)

    assert result == %{
             horizontal_lines: [{{-1, -1}, {3, -1}}, {{-1, 1}, {3, 1}}],
             vertical_lines: [{{-1, -1}, {-1, 1}}, {{3, -1}, {3, 1}}],
             intersects: %{
               {-1, -1} => :down_and_right,
               {-1, 1} => :up_and_right,
               {1, -1} => :horizontal,
               {1, 1} => :horizontal,
               {3, -1} => :down_and_left,
               {3, 1} => :up_and_left
             }
           }
  end
end
