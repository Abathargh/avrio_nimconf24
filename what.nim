import nimib

template what*: untyped =
  slide:
    nbText: "## What I'm going to talk about"
    unorderedList:
      listItem: nbText: "Writing code for AVR chips and the state of tooling"
      listItem: nbText: "Nim for embedded software development"
      listItem: nbText: "avr_io: programming MCUs in nim"
      listItem: nbText: "examples and coding an app"
      listItem: nbText: "contributing and what's next"
