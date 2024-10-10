import nimib

template avrman_pres*: untyped =
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
