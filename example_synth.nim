import nimib

template example_synth*: untyped =
  slide:
    nbText: "## example: building a synth"
    slide: nbText: "Let's implement a synth with an AY38910a PSG"
    slide: 
      nbText: "Full working code"
      nbText: "github.com/Abathargh/ay38910a_nim"
    slide: nbImage("assets/ay_chip.jpg")
    slide: nbImage("assets/ay_schema.png")
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
    slide: nbVideo("assets/sweep.mp4")
