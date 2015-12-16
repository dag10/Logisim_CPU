# Virtual Machine

I made this in 2015 as an excercise in learning Swift. It can execute
(and even help you debug) assembly programs compiled with
[assembler.swf](../assembler.swf).
See [Running Programs](#running-programs) for instructions.

## Building the VM

Feel free to use Xcode with the xcodeproj file.

Otherwise, if using the command line Swift compiler:

```
cd VM/VM
swift build --configuration release
```

## Creating programs for the VM

Open [assembler.swf](../assembler.swf), paste in the assembly, and click
Assemble. If your program uses INC, DEC, PUSH, POP, CALL, or RET, you'll need
to check off the corresponding checkboxes at the top. I know I know, the assembler
is hilarious. I made it when I was 14.

Your assembly targeting the VM will have to be a little bit different than
assembly targeting the Logisim CPU.

- The Logisim CPU's load point is 0x400, but the VM's load point is 0x000.

- The Logisim CPU's Keyboard/Display device is mapped to 0xC02.
  The VM's is mapped to 0xFFF (the highest memory address).

Note: Due a bug in the assembler, the `.stack` directive does nothing. The
      bottom (highest address) of the stack will seemingly always be 0x7FF.
      Your program almost definitely won't be so long as to cause this to
      interfere.

## <a name="running-programs"></a> Running programs

The program takes two arguments: code.txt, and map.txt (which is optional).

The `code.txt` file contains the bytecode output from assembler.swf. It's 4 hex characters per line.

The `map.txt` argument is optional. It's useful if you're debugging (uncomment `print(cpu)` in [main.swift](./VM/main.swift)), but otherwise useless. The map.txt contains the mappings also given by assembler.swf.

If using the command line Swift compiler...

```
.build/release/VM code.txt map.txt
```

Otherwise, just build with Xcode.

