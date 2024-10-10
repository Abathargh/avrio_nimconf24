template avrio_support*: untyped {.dirty.} =
  slide:
    nbText: "## avr_io: avr support in nim 👑"
    slide:
      nbText: "Binding and utilities for AVR microcontrollers in nim"
      unorderedList:
        listItem: nbText: "Requires nim >= 2.0.6"
        listItem: nbText: "Needs `avr-gcc` as its C backend compiler"
        listItem: nbText: "No other dependency"
        listItem: nbText: "github.com/Abathargh/avr_io"
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
      animateCode(1, 3, 4): 
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
        const tim0Led = 5

        proc timer0CompaIsr() {.isr(Timer0CompAVect).} =
          portB.togglePin(tim0Led)

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
      nbImage("section.png")
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
        proc usartMain = 
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
