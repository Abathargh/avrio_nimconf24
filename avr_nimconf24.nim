import std/strutils

import nimib
import nimib/blocks
import nimiSlides

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
  slide: nbText: "A couple of nice nim features"
  slide: nbText: "Allows to use low level primitives"
  slide: nbText: "Easy to check generated C code"
  slide: nbText: "Tunable memory management strategies"
  slide: nbText: "Killer-feature: compile-time and metaprogramming"
  slide: 
    nbText: "I talk at length about this here:"
    nbText: "https://dev.to/abathargh/nim-for-embedded-software-development-33cc"

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


slide:
  nbText: "## Support & limitations"
  slide:
    unorderedList:
      listItem: nbText: "Supports only a subset of AVR chips (for now)"
      unorderedList:
        listItem: nbText: "Mainly ATMega ones I can test myself"
        listItem: nbText: "The process to add a MCU is semi-automated"
      listItem: nbText: "Works with avr-gcc only"
      listItem: nbText: "Requires a bit of project configuration"
  slide:
    nbText: "panicoverride.nim"
    animateCode(1, 3, 4..8):
      proc exit(code: int) {.importc, header: "<stdlib.h>", cdecl.}
      {.push stack_trace: off, profiler:off.}
      proc rawoutput(s: string) = discard
      proc panic(s: string) =
        rawoutput(s)
        while true:
          discard
        exit(1)
      {.pop.}
    nbRawHtml: """
      <small>
      Based on 
      https://github.com/nim-lang/Nim/blob/devel/tests/avr/panicoverride.nim
      </small>"""
  slide:
    nbText: "avr-specific configs"
    nbCodeSkip:
      switch("os", "standalone")
      switch("cpu", "avr")
      switch("gc", "none")
      switch("define", "USING_ATMEGA328P")
      switch("passC", "-mmcu=atmega328p -DF_CPU=16000000")
      switch("passL", "-mmcu=atmega328p -DF_CPU=16000000")
      switch("avr.standalone.gcc.options.linker", "-static")
      switch("avr.standalone.gcc.exe", "avr-gcc")
      switch("avr.standalone.gcc.linkerexe", "avr-gcc")

slide:
  nbText: "## avrman: *avr man*ager"
  slide:
    unorderedList:
      listItem: nbText: "a tool for managing AVR projects"
      listItem: nbText: "can initialize C and nim projects"
      listItem: nbText: "avr_io is used as the base dependency for nim ones"
      listItem: nbText: "supports make and CMake for C ones"
      listItem: nbText: "github.com/Abathargh/avrman"
  slide:
    nbText: "Initialize an Arduino Uno based project"
    nbCodeSkip: 
      avrman init -m:atmega328p -f:16000000   \
                  -p:"arduino -b 115200 -P:/dev/ttyACM0" uno
    nbText: "Initialize an Arduino Uno based C project using make"
    nbCodeSkip: avrman init -m:atmega328p -f:16000000 \
      -p:"arduino -b 115200 -P:/dev/ttyACM0" --cproject uno_c
    nbText: "Initialize an Arduino Uno based C project with CMake"
    nbCodeSkip: avrman init -m:atmega328p -f:16000000 \
      -p:"arduino -b 115200 -P:/dev/ttyACM0" \ 
      --cproject --cmake uno_cmake
  slide:
    nbText: "Generated targets"
    nbCodeSkip:
      after build:
        when defined(windows):
          mvFile(bin[0] & ".exe", bin[0] & ".elf")
        else:
          mvFile(bin[0], bin[0] & ".elf")
        exec("avr-objcopy -O ihex " & bin[0] & ".elf " & bin[0] & ".hex")
        exec("avr-objcopy -O binary " & bin[0] & ".elf " & bin[0] & ".bin")

      task clear, "Deletes the previously built compiler artifacts":
        rmFile(bin[0] & ".elf")
        rmFile(bin[0] & ".hex")
        rmFile(bin[0] & ".bin")
        rmDir(".nimcache")
  slide:
    nbText: "Additional generated targets"
    nbCodeSkip:
      task flash, "Loads the compiled binary onto the MCU":
        exec("avrdude -c arduino -b 115200 -P /dev/ttyACM0 -p m328p -U flash:w:" & bin[0] & ".hex:i")

      task flash_debug, "Loads the elf binary onto the MCU":
        exec("avrdude -c arduino -b 115200 -P /dev/ttyACM0 -p m328p -U flash:w:" & bin[0] & ".elf:e")

slide:
  nbText: "## example: a simple blink application"
  slide: nbText: "Let's blink the Arduino Uno in-builtin LED at a frequency of ~1Hz"
  slide: nbText: "Full working code: github.com/Abathargh/blink_nim_demo"
  slide: nbImage("blink_init.png")
  slide: nbText: "And now... a little bit of math"
  slide:
    nbText: """$f_{MCU} = 16 MHz$"""
    nbText: """$f_{timer} = \frac{f_{MCU}}{prescaler factor} = \frac{16 MHz}{1024} = 15.625 KHz$"""
  slide:
    nbText: """$T_{timer} = \frac{1}{f_{timer}} = \frac{1}{15.625 KHz} = 64 μs$"""
    nbText: """$T_{interrupt} = T_{timer} \cdot OCRA =$""" 
    nbText: """$= 64 μs \cdot 10000 = 0,64 s$"""
  slide:
    animateCode(2..3, 6..7, 8..9, 11..12):
      import avr_io
      const 
        builtinLed = 5'u8
      
      proc initTimer1() =
        OCR1AH[] = (10000 shr 8).uint8
        OCR1AL[] = (10000 and 0xff).uint8
        timer1.setTimerFlag({TimCtlB16Flag.cs0, cs2, wgm2})
        timer1.setTimerFlag({Timsk16Flag.ociea})
      
      proc timerCompaIsr() {.isr(Timer1CompAVect).} =
        portB.togglePin(builtinLed)

  slide:
    nbCodeInBlock:
      proc loop = 
        # PORTB[5] is the Arduino Uno builtin led 
        portB.asOutputPin(builtinLed)
        initTimer1()
        sei()
        while true:
          discard
  slide: nbVideo("arduino_blink.mp4")

slide:
  nbText: "## example: building a synth"
  slide: nbText: "Let's implement a synth with an ay38910a PSGb "
  slide: nbText: "Full working code: github.com/Abathargh/ay38910a_nim"
  slide: nbImage("ay_chip.png")
  slide: nbImage("ay_schema.png")
  slide:nbText: "The clock signal gets used as the source to generate the final waveform"
  slide:nbText: "The signal gets scaled by a factor of 16, and then by an additional factor using a 12-bits integer"
  slide:
    nbText: "This means that with this clock frequency"
    nbText: """$f_{clk} = 2MHz$"""
    nbText: "We get this min and max frequencies as outputs:"
    nbText: """$f_{high} = \frac{f_{clk}}{16} = \frac{2MHz}{16} =125 KHz$"""
    nbText: """$f_{low} = \frac{f_{clk}}{16 \cdot 2^{12}} = \frac{2MHz}{16 \cdot 2^{12}}  \approx 30,5 Hz$"""
    nbText: "Range: from a $B_{0}$ to a $B_{8}$"

  slide:
    nbText: "And in general, to play a specific $f_{target}$:"
    nbText: """$f_{target} = \frac{f_{clk}}{16 \cdot m},  \text{m = 12 bit value divider}$"""
    nbText: """$f_{target} = f_{0} \cdot a^n, a = \sqrt[12]{2}, f_{0} = f_{A_{4}} = 440 Hz  $"""
    nbText: """$m = \frac{f_{clk}}{16 \cdot f_{target}} = \frac{f_{clk}}{16 \cdot 440Hz \cdot 2^{\frac{n}{12}}}$"""
  slide: nbText: "I want to have a table of coefficients to play each note in the supported range" 
  slide: nbText: "Let's use nim compile time functions for this"
  slide: nbCodeSkip:
    const 
      freq_a4 = 440 # Hz
      f_clk = 2_000_000.uint32 # Hz

    template freq(n: int16): float32 =
      freq_a4.float32 * (2.0.pow(1.0 / 12)).pow(n.float32)
  
    template mask(f: float32): uint16 =
      (f_clk div (16 * f).uint32).uint16

  slide: nbCodeSkip:
    const 
      octaves = 8
      notes_in_oct = 12
      tot_notes = notes_in_oct * octaves + 1

    proc generate_magic_notes(): array[tot_notes, uint16] =
      const
        b4_idx = 2 # A4 = 0 => B4 = 2
        b0_idx = (b4_idx - (4 * notes_in_oct)).int16
        b8_idx = (b4_idx + (4 * notes_in_oct)).int16
      var ctr = 0
      for i in b0_idx..b8_idx:
        result[ctr] = mask(freq(i))
        inc ctr
  slide: 
    nbText: "I can then write"
    nbCodeSkip:
      const 
        magicNotes* = generate_magic_notes()
    nbText: "And have a compile-time generated array with the coefficients"
  slide: nbText: "Let's write a simple ay38910 object"
  slide: animateCode(2, 5..6):
    type
      ay38910a {.byref.} = object
        bc1Pin: uint8
        bdirPin: uint8
        ctlPort: Port
        dataPort: Port
  slide: nbText: "<avr/io.h> offers a couple of delay functions"
  slide: nbText: """It's really easy to wrap one in nim thanks to its fantasticly 
  easy to use and powerful FFI"""
  slide: nbCode: 
    proc delayUs(us: uint16) 
      {.importc: "_delay_us", header: "util/delay.h".}
  slide: nbText: "But we can also implement something ad-hoc with inline asm"
  slide: nbCode:
    proc delayUs*(us: cuint) {.inline.} =
      asm """
        "MOV ZH,%B0\n\t"
        "MOV ZL,%A0\n\t"
        "%=:\n\t"
        "NOP\n\t"
        ... 12 total 'NOP's
        "SBIW Z,1\n\t"
        "BRNE %=b\n\t"
        :
        : "r" (`us`)
        : "r30", "r31"
      """
  slide: nbText: "Now we can write a couple of mode selecting functions for the PSG"
  slide: animateCode(1, 2, 3, 4):
    template writeMode(ay: ay38910a) = 
      ay.ctlPort.clearPin(ay.bc1Pin)
      delayUs(1)
      ay.ctlPort.setPin(ay.bdirPin)
      delayUs(1)
  slide: nbText: "And finally we can write data to the PSG bus"
  slide: nbCodeSkip:
    proc writeData(ay: ay38910a; address, data: uint8) = 
      ay.inactiveMode()
      ay.dataPort.setPortValue(address)
      ay.latchAddrMode()
      ay.inactiveMode()

      ay.writeMode()
      ay.dataPort.setPortValue(data)
      ay.inactiveMode()
  slide: nbText: "This allows us to implement the PSG APIs to interact with the chip"
  slide: nbCode:
    type
      channel* = enum
        CHAN_A = 0
        CHAN_B = 1
        CHAN_C = 2

      channelMode* {.size: sizeof(uint8).} = enum
        CHA_TONE  = 0
        CHB_TONE  = 1
        CHC_TONE  = 2
        CHA_NOISE = 3
        CHB_NOISE = 4
        CHC_NOISE = 5    
      channelModes* = set[channelMode]
  slide: nbCodeSkip:
    proc channelOn(ay: sink ay38910a, m: channelModes) =
      ay.writeData(MIXER_REG, bitops.bitnot(m.toMask()))

    proc channelOff(ay: ay38910a, m: channelModes) =
      ay.writeData(MIXER_REG, m.toMask())

    proc setAmplitude(ay: ay38910a, chan: channel, amp: uint8, env: bool) =
      let amplitude = (amp and 0x0f) or (if envelope: 0x10 else: 0x00)
      ay.writeData(chanToAmplReg(chan), amplitude)
  slide: nbCodeSkip:
    proc playNote*(ay: ay38910a, chan: channel, note: uint16) =
      let actualNote = note mod magicNotes.len()
      let chanRegister = chanToReg(chan)
      let magicNote = uint16(magicNotes[actualNote])
      ay.writeData(chanRegister, uint8(magicNote) and 0xff)
      ay.writeData(chanRegister + 1, uint8(magicNote shr 8) and 0x0f)
  slide: nbCodeSkip:
    proc genClock(clockPort: Port, clockPin: uint8) =
      clockPort.asOutputPin(clockPin)
      OCR2A[] = 3
      timer2.setTimerFlag({TimCtlAFlag.wgm1, coma0})
      timer2.setTimerFlag({TimCtlBFlag.cs0})
  slide: nbText: "Let's just program the synth to do a note sweep"
  slide: nbCodeSkip:
    proc loop =
      genClock(portB, 4)
      const 
        ay = ay38910a(bc1Pin: 4, bdirPin: 5, ctlPort: portH, dataPort: portA)
      ay.init()
      ay.channelOn({CHA_TONE})
      ay.setAmplitude(CHAN_A, 15, false)
      while true:
        for oct in 0..octaves:
          for note in Note.low..Note.high:
            ay.playNote(CHAN_A, note.octave(oct))
            delayMs(20)
  slide: nbVideo("sweep.mp4")

nbSave()
