defmodule Pretty.Grid.Item do
  defstruct id: nil,
            width: nil,
            height: nil,
            column_span: 1,
            row_span: 1,
            row: nil,
            column: nil,
            x: nil,
            y: nil

  @type t :: %{
          id: integer | nil,
          width: pos_integer | nil,
          height: pos_integer | nil,
          column_span: pos_integer | nil,
          row_span: pos_integer | nil,
          row: pos_integer | nil,
          column: pos_integer | nil,
          x: non_neg_integer() | nil,
          y: non_neg_integer() | nil
        }

  def empty(empty_id) do
    %__MODULE__{
      id: empty_id,
      width: 0,
      height: 0,
      column_span: 1,
      row_span: 1,
      row: nil,
      column: nil,
      x: nil,
      y: nil
    }
  end
end
