import nimib

template outro*: untyped =
  slide:
    nbText: "## Contributing and next steps"
    unorderedList:
      listItem: nbText: "Add support for other MCUs (all arvdude ones)"
      listItem: nbText: "Add other peripherals"
      listItem: nbText: "Add far-ptr progmem support"
      listItem: nbText: "System macro for vector relocation & similar stuff"
  slide: nbText: "# That's all, grazie per l'attenzione!"
