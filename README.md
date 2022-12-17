# Pretty

Pretty printing library

@WIP

Intro
-----

```
iex> p = Pretty.from([1])
iex> IO.puts p
╭   ╮
│ 1 │
╰   ╯
:ok
iex> p = Pretty.from({p, p})
iex> IO.puts p
╭              ╮
│ ╭   ╮  ╭   ╮ │
┤ │ 1 │  │ 1 │ ├
│ ╰   ╯  ╰   ╯ │
╰              ╯
:ok
iex> p = Pretty.grid([1, 2, 3], rows: 2)
iex> IO.puts p
╭───┬───╮
│ 1 │ 2 │
├───┼───┤
│ 3 │   │
╰───┴───╯
:ok
iex> p = Pretty.grid([p, 4], align_items: :center)
iex> IO.puts p
╭───────────┬───╮
│ ╭───┬───╮ │   │
│ │ 1 │ 2 │ │   │
│ ├───┼───┤ │ 4 │
│ │ 3 │   │ │   │
│ ╰───┴───╯ │   │
╰───────────┴───╯
:ok
iex> p = Pretty.matrix([["x"], ["o", "x"], ["o", "o", "x"]])
iex> IO.puts p
╭───┬───┬───╮
│ x │   │   │
├───┼───┼───┤
│ o │ x │   │
├───┼───┼───┤
│ o │ o │ x │
╰───┴───┴───╯
:ok
```
