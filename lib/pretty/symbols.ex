defmodule Pretty.Symbols do
  @moduledoc """
  Predefined symbol maps.
  """

  def box(:rounded) do
    %{
      :down_and_horizontal => "┬",
      :down_and_left => "╮",
      :down_and_right => "╭",
      :horizontal => "─",
      :up_and_horizontal => "┴",
      :up_and_left => "╯",
      :up_and_right => "╰",
      :vertical => "│",
      :vertical_and_horizontal => "┼",
      :vertical_and_left => "┤",
      :vertical_and_right => "├"
    }
  end

  def box(:square) do
    %{
      :down_and_horizontal => "┬",
      :down_and_left => "┐",
      :down_and_right => "┌",
      :horizontal => "─",
      :up_and_horizontal => "┴",
      :up_and_left => "┘",
      :up_and_right => "└",
      :vertical => "│",
      :vertical_and_horizontal => "┼",
      :vertical_and_left => "┤",
      :vertical_and_right => "├"
    }
  end

  def box(:heavy) do
    %{
      :down_and_horizontal => "┳",
      :down_and_left => "┓",
      :down_and_right => "┏",
      :horizontal => "━",
      :up_and_horizontal => "┻",
      :up_and_left => "┛",
      :up_and_right => "┗",
      :vertical => "┃",
      :vertical_and_horizontal => "╋",
      :vertical_and_left => "┫",
      :vertical_and_right => "┣"
    }
  end

  def box(:double) do
    %{
      :down_and_horizontal => "╦",
      :down_and_left => "╗",
      :down_and_right => "╔",
      :horizontal => "═",
      :up_and_horizontal => "╩",
      :up_and_left => "╝",
      :up_and_right => "╚",
      :vertical => "║",
      :vertical_and_horizontal => "╬",
      :vertical_and_left => "╣",
      :vertical_and_right => "╠"
    }
  end

  def box(:block) do
    %{
      :down_and_horizontal => "█",
      :down_and_left => "█",
      :down_and_right => "█",
      :horizontal => "█",
      :up_and_horizontal => "█",
      :up_and_left => "█",
      :up_and_right => "█",
      :vertical => "█",
      :vertical_and_horizontal => "█",
      :vertical_and_left => "█",
      :vertical_and_right => "█"
    }
  end

  def box(), do: box(:rounded)
end
