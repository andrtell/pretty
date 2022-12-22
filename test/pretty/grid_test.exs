defmodule Pretty.GridTest do
  use ExUnit.Case
  doctest Pretty.Grid

  alias Pretty.Grid
  alias Pretty.Canvas

  def lines_renderer(
        %{
          horizontal_lines: h,
          vertical_lines: v,
          intersects: i
        } = _line_map,
        _options \\ []
      ) do
    [
      for({p1, p2} <- v, do: Pretty.Paint.line(p1, p2, "#")),
      for({p1, p2} <- h, do: Pretty.Paint.line(p1, p2, "#")),
      for({p, _v} <- i, do: Pretty.Paint.dot_at(p, "#"))
    ]
    |> List.flatten()
    |> Canvas.overlay()
  end

  test "it works for 1 item, no gridlines" do
    assert Grid.paint([Pretty.from("a")], nil) |> to_string == "a"
  end

  test "it works for 2 items, direction row, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b")]
    assert Grid.paint(canvases, nil, column_gap: 0, limit: 2) |> to_string == "ab"
  end

  test "it works for 2 items, direction column, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b")]

    assert Grid.paint(canvases, nil, direction: :column, limit: 2, row_gap: 0) |> to_string ==
             "a\nb"
  end

  test "it works for 3 items, direction row, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c")]

    assert Grid.paint(canvases, nil, direction: :row, limit: 2) |> to_string ==
             "a b\n   \nc  "
  end

  test "it works for 3 items, direction column, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c")]

    assert Grid.paint(canvases, nil, direction: :column, limit: 2) |> to_string ==
             "a c\n   \nb  "
  end

  test "it works for 4 items, direction row, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c"), Pretty.from("d")]

    assert Grid.paint(canvases, nil, direction: :row, limit: 2) |> to_string ==
             "a b\n   \nc d"
  end

  test "it works for 4 items, direction column, no gridlines" do
    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c"), Pretty.from("d")]

    assert Grid.paint(canvases, nil, direction: :column, limit: 2) |> to_string ==
             "a c\n   \nb d"
  end

  test "it works for 1 item, with gridlines" do
    want = ~S"""
    ###
    #a#
    ###
    """

    want = want |> String.trim()

    assert Grid.paint([Pretty.from("a")], &lines_renderer/2) |> to_string == want
  end

  test "it works for 2 items, direction row, with gridlines" do
    want = ~S"""
    #####
    #a#b#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2) |> to_string == want
  end

  test "it works for 2 items, direction column, with gridlines" do
    want = ~S"""
    ###
    #a#
    ###
    #b#
    ###
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b")]

    assert Grid.paint(canvases, &lines_renderer/2, direction: :column, limit: 2) |> to_string ==
             want
  end

  test "it works for 3 items, direction row, with gridlines" do
    want = ~S"""
    #####
    #a#b#
    #####
    #c# #
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2) |> to_string == want
  end

  test "it works for 3 items, direction column, with gridlines" do
    want = ~S"""
    #####
    #a#c#
    #####
    #b# #
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c")]

    assert Grid.paint(canvases, &lines_renderer/2, direction: :column, limit: 2) |> to_string ==
             want
  end

  test "it works for 4 items, direction row, with gridlines" do
    want = ~S"""
    #####
    #a#b#
    #####
    #c#d#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c"), Pretty.from("d")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2) |> to_string == want
  end

  test "it works for 4 items, direction column, with gridlines" do
    want = ~S"""
    #####
    #a#c#
    #####
    #b#d#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b"), Pretty.from("c"), Pretty.from("d")]

    assert Grid.paint(canvases, &lines_renderer/2, direction: :column, limit: 2) |> to_string ==
             want
  end

  test "pad_items works for 1 item, with gridlines" do
    want = ~S"""
    #####
    #   #
    # a #
    #   #
    #####
    """

    want = want |> String.trim()

    assert Grid.paint([Pretty.from("a")], &lines_renderer/2,
             pad_items: [left: 1, right: 1, top: 1, bottom: 1]
           )
           |> to_string == want
  end

  test "pad_items_left overrider pad_items" do
    want = ~S"""
    ####
    #  #
    #a #
    #  #
    ####
    """

    want = want |> String.trim()

    assert Grid.paint([Pretty.from("a")], &lines_renderer/2,
             pad_items: [left: 1, right: 1, top: 1, bottom: 1],
             pad_items_left: 0
           )
           |> to_string == want
  end

  test "justify_items left works" do
    want = ~S"""
    #######
    #a    #
    #######
    #bbbbb#
    #######
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("bbbbb")]

    assert Grid.paint(canvases, &lines_renderer/2,
             direction: :column,
             limit: 2,
             justify_items: :left
           )
           |> to_string ==
             want
  end

  test "justify_items center works" do
    want = ~S"""
    #######
    #  a  #
    #######
    #bbbbb#
    #######
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("bbbbb")]

    assert Grid.paint(canvases, &lines_renderer/2,
             direction: :column,
             limit: 2,
             justify_items: :center
           )
           |> to_string ==
             want
  end

  test "justify_items right works" do
    want = ~S"""
    #######
    #    a#
    #######
    #bbbbb#
    #######
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("bbbbb")]

    assert Grid.paint(canvases, &lines_renderer/2,
             direction: :column,
             limit: 2,
             justify_items: :right
           )
           |> to_string ==
             want
  end

  test "justify_items works with padding" do
    want = ~S"""
    #########
    #       #
    #   a   #
    #       #
    #########
    #       #
    # bbbbb #
    #       #
    #########
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("bbbbb")]

    assert Grid.paint(canvases, &lines_renderer/2,
             direction: :column,
             limit: 2,
             justify_items: :center,
             pad_items: [left: 1, right: 1, top: 1, bottom: 1]
           )
           |> to_string ==
             want
  end

  test "align_items top works" do
    want = ~S"""
    #####
    #a#b#
    # #b#
    # #b#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b\nb\nb")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2, align_items: :top) |> to_string ==
             want
  end

  test "align_items center works" do
    want = ~S"""
    #####
    # #b#
    #a#b#
    # #b#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b\nb\nb")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2, align_items: :center) |> to_string ==
             want
  end

  test "align_items bottom works" do
    want = ~S"""
    #####
    # #b#
    # #b#
    #a#b#
    #####
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b\nb\nb")]

    assert Grid.paint(canvases, &lines_renderer/2, limit: 2, align_items: :bottom) |> to_string ==
             want
  end

  test "align_items works with padding" do
    want = ~S"""
    #########
    #   #   #
    #   # b #
    # a # b #
    #   # b #
    #   #   #
    #########
    """

    want = want |> String.trim()

    canvases = [Pretty.from("a"), Pretty.from("b\nb\nb")]

    assert Grid.paint(canvases, &lines_renderer/2,
             limit: 2,
             align_items: :center,
             pad_items: [left: 1, right: 1, bottom: 1, top: 1]
           )
           |> to_string == want
  end
end
