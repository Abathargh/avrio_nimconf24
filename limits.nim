import nimib

template limits*: untyped =
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
