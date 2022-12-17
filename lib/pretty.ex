defmodule Pretty do
  @moduledoc """
  Pretty printing Elixir terms and more.
  """

  @doc ~S"""
  Converts `term` to a pretty canvas.
  """
  def from(term) do
    Pretty.From.term(term)
  end
end
