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

## <a name="running-programs"></a> Running Programs

The program takes two arguments: code.txt, and map.txt (which is optional).

The `code.txt` file contains the bytecode output from assembler.swf. It's 4 hex characters per line.

The `map.txt` argument is optional. It's useful if you're debugging (uncomment `print(cpu)` in [main.swift](./VM/main.swift)), but otherwise useless. The map.txt contains the mappings also given by assembler.swf.

If using the command line Swift compiler...

```
.build/release/VM code.txt map.txt
```

Otherwise, just build with Xcode.

