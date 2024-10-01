import std/strutils

import nimib
import nimib/blocks
import nimiSlides

nbinit(theme=revealTheme)
footer("© G. Marcello, 2024, all rights reserved.")

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
  nbText: "# avr_io"
  nbText: "## bare-metal embedded development in nim"
  nbText: "Gianmarco Marcello, 2024"


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
  slide: nbText: "Still allows to use low level primitives"
  slide: nbText: "Killer-feature: compile-time and metaprogramming"
  slide: nbText: "Show basic nim avr program?"
  slide: nbText: """I talk at length about this here:
https://dev.to/abathargh/nim-for-embedded-software-development-33cc"""

slide:
  nbText: "## avr_io: avr support in nim 👑"
  slide:
    nbText: "Binding and utilities for AVR microcontrollers in nim"
    unorderedList:
      listItem: nbText: "Requires nim >= 2.0.6"
      listItem: nbText: "Needs `avr-gcc` as its C backend compiler"
      listItem: nbText: "No other dependency"
  slide:
    nbText: "Memory-mapped register definitions"
    animateCode(1, 3..6): 
      type MappedIoRegister*[T: uint8|uint16] = distinct uint16
      const
        PINA*   = MappedIoRegister[uint8](0x20)
        DDRA*   = MappedIoRegister[uint8](0x21)
        PORTA*  = MappedIoRegister[uint8](0x22)
        PINB*   = MappedIoRegister[uint8](0x23)
  slide:
    nbText: "Memory-mapped register definitions"
    animateCode(1, 2..3): 
      import avr_io
      proc init() =
        DDRB[] = 0b01.uint8
        PORTB[] = PORTB[] or 1.uint8

  slide:
    nbText: "Interrupt vector definitions"
    nbCode:
      type
        VectorInterrupt* = enum
          Int0Vect = 1,
          Int1Vect,
          PCInt0Vect,
          PCInt1Vect,
  slide:
    nbText: "Defining Interrupt Service Routines"
    animateCode(3, 4, 7):
      const tim1Led = 5

      proc timer1CompaIsr() {.isr(Timer1CompAVect).} =
        portB.togglePin(tim1Led)

      proc main =
        sei()
        # other logic here ...
        while true:
          discard
  slide:
    nbText: "Program memory support"
    animateCode(3, 4, 5, 6, 7, 8):
      import avr_io
      let 
        testFloat {.progmem.} = 11.23'f32
        testInt1  {.progmem.} = 12'u8
        testInt2  {.progmem.} = 13'u16
        testInt3  {.progmem.} = 14'u32
        testStr   {.progmem.} = "test progmem string\n"
        testArr   {.progmem.} = [116'u8, 101, 115, 116]
  slide:
    nbText: "Program memory support (objects, pt.1)"
    animateCode(2..4, 5..7, 8..10):
      type 
        foo = object
          f1: int16
          f2: float32
        bar = object
          b1: bool 
          b2: string 
        foobar = object
          fb1: bool 
          fb2: foo 
  slide:
    nbText: "Program memory support (objects, pt.2)"
    animateCode(3, 4, 5..8):
      import avr_io
      let 
        testObj1 {.progmem.} = foo(f1: 42'i16, f2: 45.67)
        testObj2 {.progmem.} = bar(b1: true, b2: "test\n")
        testObj3 {.progmem.} = foobar(
          fb1: false, 
          fb2: foo(f1: 21, f2: 77.0)
        )
  slide:
    nbText: "System module: putting data in a specific section"
    animateCode(2..4, 7..8):
      import avr_io
      proc fill[T](s: static int, v: T): array[s, T] {.compileTime.} =
        for i in 0..<s:
          result[i] = v
      const
        headerSize = 24
      let 
        header {.section(".metadata").} = fill(headerSize, 0'u8)
  slide:
    nbText: "Perpiheral support (partial, experimental)"
    unorderedList:
      listItem: nbText: "Not part of the original project idea, nice to have"
      listItem: nbText: "uart/usart"
      listItem: nbText: "timers"
  slide:
    nbText: "Perpiheral support: usart module"
    animateCode(3, 4, 5, 7..9):
      import avr_io
      proc loop = 
        const baud = baudRate(9600'u32) 
        usart0.initUart(baud, {}, {txen, rxen}, {ucsz1, ucsz0})
        var buf: array[100, cchar]
        while true:
          discard usart0.readLine(buf) 
          usart0.sendString(buf)
          usart0.sendByte('\n')

  slide:
    nbText: "Perpiheral support: timer module"
    animateCode(9..11):
      import avr_io
      proc initCompareMatchTimer0  =
        const
          tim0Out = 6
          mcuFreq = 16e6.uint32 # 16MHz
          desFreq = 2e6.uint32  #  2MHz
          ocrVal = ((mcuFreq div (2 * desFreq)) - 1)
        portD.asOutputPin(tim0Out)
        timer0.setTimerFlag({TimCtlAFlag.coma0, wgm1})
        timer0.setTimerFlag({TimCtlBFlag.cs0})
        timer0.ocra[] = ocrVal.uint8


nbSave()