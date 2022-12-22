defmodule Pretty.Types do
  @type index :: non_neg_integer
  @type count :: pos_integer
  @type size :: non_neg_integer

  @type sizes :: %{T.index() => T.size()}
  @type offsets :: %{T.index() => {T.index(), T.index()}}

  @type point :: {index(), index()}
  @type line :: {point(), point()}
end
