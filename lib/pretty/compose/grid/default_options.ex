defmodule Pretty.Compose.Grid.DefaultOptions do

  def put(options) do
    options
    |> align_items()
    |> column_gap()
    |> justify_items()
    |> pad_items()
    |> row_gap()
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
    options =
      case Keyword.get(options, :pad_items) do
        [t, r, b, l] ->
          options
          |> Keyword.put_new(:pad_items_top, t)
          |> Keyword.put_new(:pad_items_right, r)
          |> Keyword.put_new(:pad_items_bottom, b)
          |> Keyword.put_new(:pad_items_left, l)

        [v, h] ->
          options
          |> Keyword.put_new(:pad_items_top, v)
          |> Keyword.put_new(:pad_items_right, h)
          |> Keyword.put_new(:pad_items_bottom, v)
          |> Keyword.put_new(:pad_items_left, h)

        [a] ->
          options
          |> Keyword.put_new(:pad_items_top, a)
          |> Keyword.put_new(:pad_items_right, a)
          |> Keyword.put_new(:pad_items_bottom, a)
          |> Keyword.put_new(:pad_items_left, a)

        nil ->
          options

        [] ->
          raise ArgumentError,
            message: "the `:pad_items` option must be a list of 1, 2, or 4 integers"
      end

    options
    |> Keyword.put_new(:pad_items_top, 0)
    |> Keyword.put_new(:pad_items_right, 0)
    |> Keyword.put_new(:pad_items_bottom, 0)
    |> Keyword.put_new(:pad_items_left, 0)
  end
end
