defmodule Pretty.Symbols do
  @moduledoc false

  def get([:block]) do
    %{
      :full_block => "█",
      :left_five_eighths => "▋",
      :left_half => "▌",
      :left_one_eighth => "▏",
      :left_one_quarter => "▎",
      :left_seven_eighths => "▉",
      :left_three_eighths => "▍",
      :left_three_quarters => "▊",
      :lower_five_eighths => "▅",
      :lower_half => "▄",
      :lower_one_eighth => "▁",
      :lower_one_quarter => "▂",
      :lower_seven_eighths => "▇",
      :lower_three_eighths => "▃",
      :lower_three_quarters => "▆",
      :right_half => "▐",
      :upper_half => "▀"
    }
  end

  def get([:box, :light]) do
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

  def get([:box, :light, :arc]) do
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

  def get([:box, :heavy]) do
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

  def get([:box, :double]) do
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

  def get(_), do: nil
end
