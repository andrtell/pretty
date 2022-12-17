defmodule Pretty.Compose.Grid.Collect do
  @moduledoc false

  def canvas_offsets(layout) do
    layout
    |> Enum.map(fn tag ->
      case tag do
        {:canvas, [x0, y0, _, _], _} -> {x0, y0}
        _ -> :ignore
      end
    end)
    |> Enum.filter(fn tag -> tag != :ignore end)
  end

  @doc """
  Get a list of grid lines from a layout
  """
  def lines_map(layout) do
    xs = grid_lines_xs(layout)
    ys = grid_lines_ys(layout)

    xs_interior = xs |> Enum.slice(1..-2)
    ys_interior = ys |> Enum.slice(1..-2)

    x_first = List.first(xs)
    x_last = List.last(xs)

    y_first = List.first(ys)
    y_last = List.last(ys)

    verticals = Enum.map(xs, fn x -> {{x, y_first}, {x, y_last}} end)
    horizontals = Enum.map(ys, fn y -> {{x_first, y}, {x_last, y}} end)

    top = for x <- xs_interior, do: {x, y_first}
    bottom = for x <- xs_interior, do: {x, y_last}

    left = for y <- ys_interior, do: {x_first, y}
    right = for y <- ys_interior, do: {x_last, y}

    cross = for x <- xs_interior, y <- ys_interior, do: {x, y}

    corners = %{
      top_left: {x_first, y_first},
      top_right: {x_last, y_first},
      bottom_left: {x_first, y_last},
      bottom_right: {x_last, y_last}
    }

    %{
      verticals: verticals,
      horizontals: horizontals,
      intersects: %{
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        cross: cross
      },
      corners: corners
    }
  end

  # Returns the vertical grid lines from a list of tags.
  defp grid_lines_xs(layout) do
    layout
    |> Enum.map(fn tag ->
      case tag do
        {:grid_start, [x0, _, _, _], _} ->
          x0

        {:grid_end, [_, _, x1, _], _} ->
          x1 - 1

        {:column_gap, [x0, _, x1, _], _} ->
          wd = x1 - x0
          x0 + ceil(wd / 2) - 1

        _ ->
          :ignore
      end
    end)
    |> Enum.filter(fn tag -> tag != :ignore end)
    |> Enum.uniq()
  end

  # Returns the horizontal grid lines from a list of tags.
  defp grid_lines_ys(layout) do
    layout
    |> Enum.map(fn tag ->
      case tag do
        {:grid_start, [_, y0, _, _], _} ->
          y0

        {:grid_end, [_, _, _, y1], _} ->
          y1 - 1

        {:row_gap, [_, y0, _, y1], _} ->
          ht = y1 - y0
          y0 + ceil(ht / 2) - 1

        _ ->
          :ignore
      end
    end)
    |> Enum.filter(fn tag -> tag != :ignore end)
    |> Enum.uniq()
  end
end
