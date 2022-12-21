defmodule Pretty.Layout.SizingTest do
  use ExUnit.Case
  doctest Pretty.Layout.Sizing

  alias Pretty.Layout.Sizing

  setup do
    item1 = %{
      id: 1,
      row: 0,
      column: 0,
      row_span: 1,
      column_span: 1,
      width: 1,
      height: 1
    }

    item2 = %{
      id: 2,
      row: 0,
      column: 1,
      row_span: 1,
      column_span: 1,
      width: 1,
      height: 1
    }

    {:ok, item1: item1, item2: item2}
  end

  test "works for 1 item", context do
    item = context[:item1]
    ret = Sizing.size_items([item], 1, 1, 0, 0)
    assert ret == {[item], %{0 => 1}, %{0 => 1}}
  end

  test "sets dims, 1 item", context do
    item = %{context[:item1] | width: 3, height: 5}
    ret = Sizing.size_items([item], 1, 1, 0, 0)
    assert ret == {[item], %{0 => 5}, %{0 => 3}}
  end

  test "sets dims, 2 items, 1 row and 2 columns", context do
    item1 = %{context[:item1] | row: 0, column: 0}
    item2 = %{context[:item2] | row: 0, column: 1}
    ret = Sizing.size_items([item1, item2], 1, 2, 0, 0)
    assert ret == {[item1, item2], %{0 => 1}, %{0 => 1, 1 => 1}}
  end

  test "sets dims, 2 items, 2 rows and 1 column", context do
    item1 = %{context[:item1] | width: 3, height: 5, row: 0, column: 0}
    item2 = %{context[:item1] | width: 3, height: 5, row: 1, column: 0}
    ret = Sizing.size_items([item1, item2], 2, 1, 0, 0)
    assert ret == {[item1, item2], %{0 => 5, 1 => 5}, %{0 => 3}}
  end

  test "sets item width, 2 items, 2 rows", context do
    item1 = %{context[:item1] | width: 10, height: 10, row: 0, column: 0}
    item2 = %{context[:item2] | width: 5, height: 5, row: 1, column: 0}
    ret = Sizing.size_items([item1, item2], 2, 1, 0, 0)
    assert ret == {[item1, %{item2 | width: 10}], %{0 => 10, 1 => 5}, %{0 => 10}}
  end

  test "sets item height, 2 items, 2 columns", context do
    item1 = %{context[:item1] | width: 10, height: 10, row: 0, column: 0}
    item2 = %{context[:item2] | width: 5, height: 5, row: 0, column: 1}
    ret = Sizing.size_items([item1, item2], 1, 2, 0, 0)
    assert ret == {[item1, %{item2 | height: 10}], %{0 => 10}, %{0 => 10, 1 => 5}}
  end
end
