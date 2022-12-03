defmodule Pretty.Grid.Lines do
  alias Pretty.Types, as: T

  @type line_item :: %{
          row: T.index(),
          column: T.index(),
          row_span: T.size(),
          column_span: T.size()
        }

  @type line_map :: %{
          horizontal_lines: [T.line()],
          vertical_lines: [T.line()],
          intersects: %{
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

  @doc ~S"""
  Given a list of items, return a map of lines to paint a grid.

  ╭───┬───╮ - horizontal_lines
  │ 1 │ 2 │
  ├───┼───┤ - horizontal_lines
  │ 3 │   │
  ╰───┴───╯ - horizontal_lines
  |   |   |
  vertical_lines

  intersects: ({0, 0} => :down_and_right, ..., {2, 2} => :down_and_horizontal,  ...)
  """
  @spec make_lines([line_item], T.offsets(), T.offsets()) :: line_map
  def make_lines(items, row_gap_offsets, column_gap_offsets) do
    line_map = %{
      horizontal_lines: [],
      vertical_lines: [],
      intersects: %{}
    }

    line_map =
      Enum.reduce(items, line_map, fn item, line_map ->
        make_lines_for_item(item, line_map, row_gap_offsets, column_gap_offsets)
      end)

    %{
      line_map
      | horizontal_lines: Enum.uniq(line_map.horizontal_lines),
        vertical_lines: Enum.uniq(line_map.vertical_lines),
        intersects: pretty_intersections(line_map.intersects)
    }
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
      | horizontal_lines:
          [
            {{x_left, y_top}, {x_right, y_top}},
            {{x_left, y_bottom}, {x_right, y_bottom}}
          ] ++ line_map.horizontal_lines,
        vertical_lines:
          [
            {{x_left, y_top}, {x_left, y_bottom}},
            {{x_right, y_top}, {x_right, y_bottom}}
          ] ++ line_map.vertical_lines,
        intersects:
          Map.merge(
            line_map.intersects,
            %{
              {x_left, y_top} => %{r: true, d: true},
              {x_right, y_top} => %{l: true, d: true},
              {x_left, y_bottom} => %{r: true, u: true},
              {x_right, y_bottom} => %{l: true, u: true}
            },
            fn _, m1, m2 -> Map.merge(m1, m2) end
          )
    }

    # row span, vertical_lines lines, fill in the gaps
    line_map =
      if item.row_span > 1 do
        Enum.reduce(
          (item.row + 1)..last_row,
          line_map,
          fn row, line_map ->
            {y_top, _y_bottom} = Map.get(row_gap_offsets, row)

            %{
              line_map
              | intersects:
                  Map.merge(
                    line_map.intersects,
                    %{
                      {x_left, y_top} => %{u: true, d: true},
                      {x_right, y_top} => %{u: true, d: true}
                      # {x_left, y_bottom} => %{u: true, d: true},
                      # {x_right, y_bottom} => %{u: true, d: true}
                    },
                    fn _, m1, m2 -> Map.merge(m1, m2) end
                  )
            }
          end
        )
      else
        line_map
      end

    # column span, horizontal_lines lines, fill in the gaps
    if item.column_span > 1 do
      Enum.reduce((item.column + 1)..last_column, line_map, fn col, line_map ->
        {x_left, _} = Map.get(column_gap_offsets, col)

        %{
          line_map
          | intersects:
              Map.merge(
                line_map.intersects,
                %{
                  {x_left, y_top} => %{l: true, r: true},
                  # {x_right, y_top} => %{l: true, r: true},
                  {x_left, y_bottom} => %{l: true, r: true}
                  # {x_right, y_bottom} => %{l: true, r: true}
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
