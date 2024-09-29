import std/strutils

import nimib
import nimib/blocks
import nimiSlides

nbinit(theme=revealTheme)

# modified code blocks

template nimConfTheme*() =
  setSlidesTheme(Black)
  let nimYellow = "#FFE953"
  nb.addStyle: """
:root {
  --r-background-color: #181922;
  --r-heading-color: $1;
  --r-link-color: $1;
  --r-selection-color: $1;
  --r-link-color-dark: darken($1 , 15%)
}

.reveal ul, .reveal ol {
  display: block;
  text-align: left;
}

li::marker {
  color: $1;
  content: "»";
}

li {
  padding-left: 12px;
}
""" % [nimYellow]

nimConfTheme()


slide:
  nbText: """
# avr_io
## bare-metal embedded development in nim
Gianmarco Marcello, 2024
"""

slide:
  nbText: "## Ultra-quick about me:"
  unorderedList:
    listItem: nbText: "Gianmarco, from Italy  "
    listItem: nbText: "Embedded Software Engineer"
    listItem: nbText: "AVR enthusiast, like to hack around on MCUs"
    listItem: nbText: "g.marcello@antima.it"
    listItem: nbText: "github.com/Abathargh"

slide:
  nbText: "## What I'm going to talk about"
  unorderedList:
    listItem: nbText: "Writing code for AVR chips and the state of tooling"
    listItem: nbText: "Nim for embedded software development"
    listItem: nbText: "avr_io: programming MCUs in nim"
    listItem: nbText: "examples and coding an app"
    listItem: nbText: "contributing and what's next"

slide:
  nbText: "## The AVR embedded landscape"
  slide:
    nbText: "### Platforms:"
    nbText: "8-bit MCUs are ubiquitous even in the 32-bit MCU era"
    nbText: "Popular platform for hobbyists (Arduino UNO et al.)"
    nbText: "Easy to use on their own (PDIP packages, good quality datasheets)"
  slide:
    nbImage("arduino.jpg")
  slide:
    nbImage("mcu.jpg")
  slide:
    nbImage("board.jpg")
    
  slide:
    nbText: "### PROs"
    unorderedList:
      listItem: nbText: "C based"
      listItem: nbText: "Very nice tooling"
      unorderedList:
        listItem: nbText: "GCC frontend"
        listItem: nbText: "avr-libc"
        listItem: nbText: "avrdude"
        listItem: nbText: "nice debugging story: bloom"
  slide:
    nbText: "### CONs"
    unorderedList:
      listItem: nbText: "C is not very ergonomic"
      listItem: nbText: "Hard to get it right"
      listItem: nbText: "Weak feature set"


slide:
  nbText: "## Using nim to program microcontrollers"
  slide: nbText: "Almost all of the weakness in C are \"fixed\" by nim"
  slide: nbText: "Killer-feature: compile-time stuff and metaprogramming"
  slide: nbText: "https://dev.to/abathargh/nim-for-embedded-software-development-33cc"


nbSave()