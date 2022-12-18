defmodule Pretty.Layout.Grid.DefaultOptions do
  @moduledoc false

  def put(options) do
    options
    |> rows_and_columns()
    |> align_items()
    |> column_gap()
    |> justify_items()
    |> pad_items()
    |> row_gap()
  end

  def rows_and_columns(options) do
    rows = Keyword.get(options, :rows, 0)
    columns = Keyword.get(options, :columns, 0)

    mode = if columns > 0, do: :by_column, else: :by_row

    options
    |> Keyword.put(:grid_mode, mode)
    |> Keyword.put(:rows, rows)
    |> Keyword.put(:columns, columns)
  end

  def align_items(options) do
    Keyword.put_new(options, :align_items, :left)
  end

  def justify_items(options) do
    Keyword.put_new(options, :justify_items, :left)
  end

  def row_gap(options) do
    Keyword.put_new(options, :row_gap, 1)
  end

  def column_gap(options) do
    Keyword.put_new(options, :column_gap, 1)
  end

  def pad_items(options) do
    pad_items = Keyword.get(options, :pad_items, [])

    pad_items_left = Keyword.get(pad_items, :left, 0)
    pad_items_right = Keyword.get(pad_items, :right, 0)
    pad_items_top = Keyword.get(pad_items, :top, 0)
    pad_items_bottom = Keyword.get(pad_items, :bottom, 0)

    options
    |> Keyword.put_new(:pad_items_top, pad_items_top)
    |> Keyword.put_new(:pad_items_right, pad_items_right)
    |> Keyword.put_new(:pad_items_bottom, pad_items_bottom)
    |> Keyword.put_new(:pad_items_left, pad_items_left)
  end
end
