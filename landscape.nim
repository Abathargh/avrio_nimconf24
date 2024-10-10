import nimib

template landscape*: untyped =
  slide:
    nbText: "## The AVR embedded landscape"
    slide:
      nbText: "### Platforms:"
      nbText: "8-bit MCUs are ubiquitous even in the 32-bit MCU era"
      nbText: "Popular platform for hobbyists (Arduino UNO et al.)"
      nbText: "Easy to use on their own (PDIP packages, good quality datasheets)"
    slide:
      nbImage("assets/arduino.jpg")
    slide:
      nbImage("assets/mcu.jpg")
    slide:
      nbImage("assets/board.jpg")
      
    slide:
      nbText: "### PROs"
      unorderedList:
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
        listItem: nbText: "C++ is even less ergonomic"
        listItem: nbText: "Hard to get it right"
        listItem: nbText: "Weak feature set"

  slide:
    nbText: "## Using nim to program microcontrollers"
    slide: 
      nbText: "Almost all of the weaknesses in C are \"fixed\" by nim"
      unorderedList:
        listItem: nbText: "Array to pointer decay"
        listItem: nbText: "Stricter type-system"
        listItem: nbText: "Array access checks (tunable)"
        listItem: nbText: "Hygienic macros, bit fields"
    slide: nbText: "A couple of nice nim features"
    slide: nbText: "Allows to use low level primitives"
    slide: nbText: "Easy to check generated C code"
    slide: nbText: "Tunable memory management strategies"
    slide: nbText: "Killer-feature: compile-time and metaprogramming"
    slide: 
      nbText: "I talk at length about this here:"
      nbText: "https://dev.to/abathargh/nim-for-embedded-software-development-33cc"
