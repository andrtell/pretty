defmodule Pretty.Compose.Grid.Layout do
  @moduledoc false

  alias Pretty.Canvas

  @doc """
  Takes a list of canvases and returns a list of tags.
  """
  def create(canvases, row_count, nth_row_column_count, line_hints, options) do
    options = Keyword.put(options, :line_hints, line_hints)
    tags = tag_grid(canvases, row_count, nth_row_column_count, options)
    fit_tags(tags, options)
  end

  defp tag_grid(canvases, row_count, nth_row_column_count, options) do
    tags = tag_grid_start([], options)
    {_, tags} = tag_rows(canvases, tags, row_count, nth_row_column_count, options)
    tags = tag_grid_end(tags, options)
    Enum.reverse(tags)
  end

  defp tag_rows([], tags, _, _, _) do
    {[], tags}
  end

  defp tag_rows(canvases, tags, row_index, _, _) when row_index <= 0 do
    {canvases, tags}
  end

  defp tag_rows(canvases, tags, row_index, [column_count | nth_row_column_count], options)
       when row_index > 0 do
    tags = tag_row_start(tags, options)
    {canvases, tags} = tag_columns(canvases, tags, row_index, column_count, options)
    tags = tag_row_end(tags, options)

    tags =
      if row_index > 1 && !Enum.empty?(canvases),
        do: make_row_separator_tags(tags, options),
        else: tags

    tag_rows(canvases, tags, row_index - 1, nth_row_column_count, options)
  end

  defp make_row_separator_tags(tags, options) do
    tags
    |> tag_row_start(options)
    |> tag_row_gap(options)
    |> tag_row_end(options)
  end

  defp tag_columns([], tags, _, _, _) do
    {[], tags}
  end

  defp tag_columns(canvases, tags, _, column_index, _) when column_index <= 0 do
    {canvases, tags}
  end

  defp tag_columns(canvases, tags, row_index, column_index, options) when column_index > 0 do
    {canvases, tags} = tag_canvas(canvases, tags, options)

    tags =
      if column_index > 1 && !Enum.empty?(canvases),
        do: tag_column_gap(tags, options),
        else: tags

    tag_columns(canvases, tags, row_index, column_index - 1, options)
  end

  defp tag_canvas([canvas | rest], tags, options) do
    top = Keyword.get(options, :pad_items_top, 0)
    right = Keyword.get(options, :pad_items_right, 0)
    bottom = Keyword.get(options, :pad_items_bottom, 0)
    left = Keyword.get(options, :pad_items_left, 0)

    [x0, y0, x1, y1] = Canvas.box(canvas)

    tags = [
      {
        :canvas,
        [
          0,
          0,
          x1 - x0 + right + left,
          y1 - y0 + bottom + top
        ],

        # bounding box
        # meta
        %{}
      }
      | tags
    ]

    {rest, tags}
  end

  defp tag_canvas([], tags, _opts) do
    {[], tags}
  end

  defp tag_grid_start(tags, options) do
    line_hints = Keyword.get(options, :line_hints, [])
    top_hint = Keyword.get(line_hints, :top, 0)

    [{:grid_start, [0, 0, 0, top_hint], nil} | tags]
  end

  defp tag_grid_end(tags, options) do
    line_hints = Keyword.get(options, :line_hints, [])
    bottom_hint = Keyword.get(line_hints, :bottom, 0)

    [{:grid_end, [0, 0, 0, bottom_hint], nil} | tags]
  end

  defp tag_row_start(tags, options) do
    line_hints = Keyword.get(options, :line_hints, [])
    left_hint = Keyword.get(line_hints, :left, 0)

    [{:row_start, [0, 0, left_hint, 0], nil} | tags]
  end

  defp tag_row_end(tags, options) do
    line_hints = Keyword.get(options, :line_hints, [])
    right_hint = Keyword.get(line_hints, :right, 0)

    [{:row_end, [0, 0, right_hint, 0], nil} | tags]
  end

  defp tag_row_gap(tags, options) do
    row_gap = Keyword.get(options, :row_gap, 0)
    [{:row_gap, [0, 0, 0, row_gap], nil} | tags]
  end

  defp tag_column_gap(tags, options) do
    column_gap = Keyword.get(options, :column_gap, 0)
    [{:column_gap, [0, 0, column_gap, 0], nil} | tags]
  end

  #
  # Fit tags
  #

  defp fit_tags(tags, options) do
    tags
    |> fit_tags_to_columns(column_offsets(tags), options)
    |> fit_tags_to_rows(row_offsets(tags), options)
  end

  defp fit_tags_to_columns(tags, column_offsets, options) do
    {fitted, _} =
      Enum.reduce(
        tags,
        {[], column_offsets},
        fn tag, {fitted, offsets} ->
          offsets =
            case tag do
              {:grid_end, _, _} -> [List.last(column_offsets)]
              {:row_start, _, _} -> column_offsets
              _ -> offsets
            end

          [offset | rest] = offsets

          tag =
            case tag do
              {:canvas, _, _} ->
                [next_offset | _] = rest

                tag
                |> justify_tag(offset, next_offset, options)

              _ ->
                tag
            end

          tag = translate_tag(tag, offset, 0)

          rest =
            case tag do
              {:row_end, _, _} -> column_offsets
              _ -> rest
            end

          {[tag | fitted], rest}
        end
      )

    Enum.reverse(fitted)
  end

  defp fit_tags_to_rows(tags, row_offsets, options) do
    {fitted, _} =
      Enum.reduce(
        tags,
        {[], row_offsets},
        fn tag, {fitted, [offset | rest] = offsets} ->
          case tag do
            {:grid_start, _, _} ->
              # consume the first offset
              {[translate_tag(tag, 0, offset) | fitted], rest}

            {:row_end, _, _} ->
              [next_offset | _] = rest
              {[translate_tag(tag, 0, next_offset) | fitted], rest}

            {:canvas, _, _} ->
              [next_offset | _] = rest

              tag =
                tag
                |> align_tag(offset, next_offset, options)
                |> translate_tag(0, offset)

              {[tag | fitted], offsets}

            _ ->
              tag = translate_tag(tag, 0, offset)

              {[tag | fitted], offsets}
          end
        end
      )

    Enum.reverse(fitted)
  end

  defp justify_tag({_, [x0, _, x1, _], _} = tag, curr_offset, next_offset, options) do
    justify_items = Keyword.get(options, :justify_items, :left)

    left = Keyword.get(options, :pad_items_left, 0)

    tag_width = x1 - x0

    case justify_items do
      :right ->
        dx = next_offset - curr_offset - tag_width
        translate_tag(tag, dx + left, 0)

      :center ->
        cell_width = next_offset - curr_offset
        dx = ceil((cell_width - tag_width) / 2)
        translate_tag(tag, dx + left, 0)

      :left ->
        translate_tag(tag, left, 0)
    end
  end

  #
  #
  #
  defp align_tag({_, [_, y0, _, y1], _} = tag, curr_offset, next_offset, options) do
    align_items = Keyword.get(options, :align_items, :top)

    top = Keyword.get(options, :pad_items_top, 0)

    tag_height = y1 - y0

    case align_items do
      :bottom ->
        dy = next_offset - curr_offset - tag_height
        translate_tag(tag, 0, dy + top)

      :center ->
        cell_height = next_offset - curr_offset
        dy = floor((cell_height - tag_height) / 2)
        translate_tag(tag, 0, dy + top)

      _ ->
        translate_tag(tag, 0, top)
    end
  end

  #
  # Offsets
  #

  defp row_offsets(tags) do
    row_heights(tags, 0, [])
    |> offsets
  end

  defp column_offsets(tags) do
    column_widths(tags, [], [])
    |> offsets
  end

  defp offsets(lst) do
    [0 | Enum.scan(lst, 0, &(&1 + &2))]
  end

  #
  # Dimensions
  #

  defp row_heights([], _, row_hts) do
    Enum.reverse(row_hts)
  end

  defp row_heights([tag | rest], max_ht, row_hts) do
    tag_ht = tag_height(tag)

    max_ht =
      case tag do
        {:grid_start, _, _} -> 0
        {:grid_end, _, _} -> 0
        {:row_start, _, _} -> tag_ht
        _ -> max(tag_ht, max_ht)
      end

    row_hts =
      case tag do
        {:grid_start, _, _} -> [tag_ht | row_hts]
        {:grid_end, _, _} -> [tag_ht | row_hts]
        {:row_end, _, _} -> [max_ht | row_hts]
        _ -> row_hts
      end

    row_heights(rest, max_ht, row_hts)
  end

  defp column_widths([], _, max_wds) do
    Enum.reverse(max_wds)
  end

  defp column_widths([tag | rest], curr_wds, max_wds) do
    tag_wd = tag_width(tag)

    curr_wds =
      case tag do
        {:grid_start, _, _} -> curr_wds
        {:grid_end, _, _} -> curr_wds
        {:row_start, _, _} -> [tag_wd]
        _ -> [tag_wd | curr_wds]
      end

    max_wds =
      case tag do
        {:row_end, _, _} -> make_max_wds(curr_wds, max_wds)
        _ -> max_wds
      end

    curr_wds =
      case tag do
        {:row_end, _, _} -> []
        _ -> curr_wds
      end

    column_widths(rest, curr_wds, max_wds)
  end

  #
  # Helpers
  #

  defp make_max_wds(curr_wds, max_wds) do
    max_len = length(max_wds)
    curr_len = length(curr_wds)

    max_wds =
      List.duplicate(
        0,
        max(0, curr_len - max_len)
      ) ++ max_wds

    curr_wds =
      List.duplicate(
        0,
        max(0, max_len - curr_len)
      ) ++ curr_wds

    Enum.zip_with(curr_wds, max_wds, &max/2)
  end

  defp translate_tag({tag_type, [x0, y0, x1, y1], meta}, x, y) do
    {tag_type, [x0 + x, y0 + y, x1 + x, y1 + y], meta}
  end

  defp tag_width({_, [x0, _, x1, _], _}), do: x1 - x0

  defp tag_height({_, [_, y0, _, y1], _}), do: y1 - y0
end
