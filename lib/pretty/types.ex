defmodule Pretty.Types do
  @type index :: non_neg_integer
  @type count :: pos_integer
  @type size :: non_neg_integer

  @type sizes :: %{index() => size()}
  @type offsets :: %{index() => {index(), index()}}

  @type point :: {index(), index()}
  @type line :: {point(), point()}
end
