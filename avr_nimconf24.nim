import nimib
import nimib/blocks
import nimiSlides

import std/strutils

import intro
import about
import what
import landscape
import avrio_support
import limits
import avrman_pres
import example_blink
import example_synth
import outro


nbinit(theme=revealTheme)
footer("© G. Marcello, 2024, all rights reserved.")
nb.useLatex()

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

intro()
about()
what()
landscape()
avrio_support()
limits()
avrman_pres()
example_blink()
example_synth()
outro()

nbSave()
