import nimib

template outro*: untyped =
  slide:
    nbText: "## Contributing and next steps"
    unorderedList:
      listItem: nbText: "add other mcus (all arvdude ones)"
      listItem: nbText: "add peripherals (SPI I2C at least)"
      listItem: nbText: "add far progmem support"
      listItem: nbText: "system macro for vector relocation"
  slide: nbText: "# That's all, grazie per l'attenzione!"
