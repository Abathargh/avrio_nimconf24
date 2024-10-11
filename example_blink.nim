import nimib

template example_blink*: untyped =
  slide:
    nbText: "## example: a simple blink application"
    slide: nbText: "Let's blink the Arduino Uno in-builtin LED at a frequency of ~1Hz"
    slide: nbText: "Full working code: github.com/Abathargh/blink_nim_demo"
    slide: nbImage("assets/blink_init.png")
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
    slide: nbVideo("assets/arduino_blink.mp4")
