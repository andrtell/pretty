defmodule Pretty.Components.Dinosaur do
  def paint() do
    Pretty.Canvas.from_string(~S"""
             ██▄▄
             ██▀▀
           ▄███▄
         ▄█████
    ▀▄▄▀▀  █▄ █▄
    """)
  end
end
