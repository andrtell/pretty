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
```
