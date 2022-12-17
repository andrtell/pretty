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

iex> p = Pretty.grid([1, 2, 3], rows: 2, symbols: Pretty.Symbols.box(:square))
iex> IO.puts p
┌───┬───┐
│ 1 │ 2 │
├───┼───┤
│ 3 │   │
└───┴───┘
:ok

iex> p = Pretty.grid([p, 4], align_items: :center)
iex> IO.puts p
╭───────────┬───╮
│ ┌───┬───┐ │   │
│ │ 1 │ 2 │ │   │
│ ├───┼───┤ │ 4 │
│ │ 3 │   │ │   │
│ └───┴───┘ │   │
╰───────────┴───╯
:ok

iex> p = Pretty.grid_layout([1, 2, 3], rows: 2, row_gap: 0)
iex> IO.puts p
1 2
3 
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

iex> p = Pretty.matrix_layout([["x"], ["o", "x"], ["o", "o", "x"]], row_gap: 0)
iex> IO.puts p
x    
o x  
o o x
:ok

iex> q = Pretty.from("@")
iex> q = Pretty.relative(q, top: 1, left: 2)
iex> IO.puts q
   
  @
:ok

iex> o = Pretty.overlay(p, q)
iex> IO.puts o
x    
o @  
o o x
:ok
```
