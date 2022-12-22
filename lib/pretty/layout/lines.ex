defmodule Pretty.Layout.Lines do
  @type line_item :: %{
          row: non_neg_integer,
          column: non_neg_integer,
          row_span: pos_integer,
          column_span: pos_integer
        }

  @type row_gap_offsets :: %{non_neg_integer => {integer, integer}}
  @type column_gap_offsets :: %{non_neg_integer => {integer, integer}}

  @type line :: {{integer, integer}, {integer, integer}}

  @type line_map :: %{
          horizontal: [line],
          vertical: [line],
          intersect: %{
            {integer, integer} =>
              :vertical
              | :horizontal
              | :down_and_right
              | :up_and_right
              | :down_and_left
              | :up_and_left
              | :vertical_and_right
              | :vertical_and_left
              | :down_and_horizontal
              | :up_and_horizontal
          }
        }

  @spec make_lines([line_item], row_gap_offsets(), column_gap_offsets()) :: line_map
  def make_lines(items, row_gap_offsets, column_gap_offsets) do
    line_map = %{
      horizontal: [],
      vertical: [],
      intersect: %{}
    }

    line_map =
      Enum.reduce(items, line_map, fn item, line_map ->
        make_lines_for_item(item, line_map, row_gap_offsets, column_gap_offsets)
      end)

    %{line_map | intersect: pretty_intersections(line_map.intersect)}
  end

  #
  # Make lines for a single item
  # 
  defp make_lines_for_item(item, line_map, row_gap_offsets, column_gap_offsets) do
    last_row = item.row + item.row_span - 1
    last_column = item.column + item.column_span - 1

    {x_left, _} = Map.get(column_gap_offsets, item.column)
    {y_top, _} = Map.get(row_gap_offsets, item.row)
    {_, x_right} = Map.get(column_gap_offsets, last_column)
    {_, y_bottom} = Map.get(row_gap_offsets, last_row)

    line_map = %{
      line_map
      | horizontal:
          [
            {{x_left, y_top}, {x_right, y_top}},
            {{x_left, y_bottom}, {x_right, y_bottom}}
          ] ++ line_map.horizontal,
        vertical:
          [
            {{x_left, y_top}, {x_left, y_bottom}},
            {{x_right, y_top}, {x_right, y_bottom}}
          ] ++ line_map.vertical,
        intersect:
          Map.merge(
            line_map.intersect,
            %{
              {x_left, y_top} => %{r: true, d: true},
              {x_right, y_top} => %{l: true, d: true},
              {x_left, y_bottom} => %{r: true, u: true},
              {x_right, y_bottom} => %{l: true, u: true}
            },
            fn _, m1, m2 -> Map.merge(m1, m2) end
          )
    }

    # row span, vertical lines, fill in the gaps
    line_map =
      if item.row_span > 1 do
        Enum.reduce(
          (item.row + 1)..(last_row - 1),
          line_map,
          fn row, line_map ->
            {y_top, y_bottom} = Map.get(row_gap_offsets, row)

            %{
              line_map
              | intersect:
                  Map.merge(
                    line_map.intersect,
                    %{
                      {x_left, y_top} => %{u: true, d: true},
                      {x_right, y_top} => %{u: true, d: true},
                      {x_left, y_bottom} => %{u: true, d: true},
                      {x_right, y_bottom} => %{u: true, d: true}
                    },
                    fn _, m1, m2 -> Map.merge(m1, m2) end
                  )
            }
          end
        )
      else
        line_map
      end

    # column span, horizontal lines, fill in the gaps
    if item.column_span > 1 do
      Enum.reduce((item.column + 1)..(last_column - 1), line_map, fn col, line_map ->
        {x_left, x_right} = Map.get(column_gap_offsets, col)

        %{
          line_map
          | intersect:
              Map.merge(
                line_map.intersect,
                %{
                  {x_left, y_top} => %{l: true, r: true},
                  {x_right, y_top} => %{l: true, r: true},
                  {x_left, y_bottom} => %{l: true, r: true},
                  {x_right, y_bottom} => %{l: true, r: true}
                },
                fn _, m1, m2 -> Map.merge(m1, m2) end
              )
        }
      end)
    else
      line_map
    end
  end

  defp pretty_intersections(intersects) do
    Enum.map(Map.to_list(intersects), fn {k, v} ->
      v =
        case v do
          %{r: true, l: true, u: true, d: true} ->
            :vertical_and_horizontal

          %{r: true, l: true, u: true} ->
            :up_and_horizontal

          %{r: true, l: true, d: true} ->
            :down_and_horizontal

          %{r: true, u: true, d: true} ->
            :vertical_and_right

          %{l: true, u: true, d: true} ->
            :vertical_and_left

          %{d: true, r: true} ->
            :down_and_right

          %{d: true, l: true} ->
            :down_and_left

          %{u: true, r: true} ->
            :up_and_right

          %{u: true, l: true} ->
            :up_and_left

          %{u: true, d: true} ->
            :vertical

          %{r: true, l: true} ->
            :horizontal

          _ ->
            :ignore
        end

      {k, v}
    end)
    |> Enum.filter(fn {_, v} -> v != :ignore end)
    |> Enum.into(%{})
  end
end
