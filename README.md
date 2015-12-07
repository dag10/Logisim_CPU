# Logisim CPU
Made a CPU in Logisim when I was 14 (2009), and wrote a naive assembler and compiler for it in Flash.

The CPU's design is inspired by Donn Stewart, http://cpuville.com.

## Compiler

The *DrewCode* compiler, written in Flash, can also compile to a Windows binary,
which is actually an emulator for the CPU compiled for Windows. You can access
it at http://compiler.drewgottlieb.net.

## Brainf*ck Interpreter

To use run the [Brainf*ck](https://en.wikipedia.org/wiki/Brainfuck) interpreter, do the following:

1. Install [Logisim](http://www.cburch.com/logisim/download.html).
1. Open assembler.swf. You'll need to have Flash Player installed on your system, or open it in Google Chrome.
2. Paste in the contents of Assembly/BFOS.asm. Hit *Assemble*, it'll hang for several seconds.
3. Copy the entirety of it output into your clipboard.
4. Open cpu_2_bf.circ in Logisim.
5. On the left side of Logisim, open the *main* circuit if it's not already opened.
6. Right click on the RAM module labeled **2K RAM** and click *Edit Contents...*
7. Paste in the bytecode. Close the memory contents window.
8. In the Logisim menu bar, select the following:
    - Simulate &rarr; Tick Frequency &rarr; 4.1 KHz.
    - Simulate &rarr; Ticks Enabled
9. Select the finger tool (key: Meta-1)
10. Click the *Toggle Clock* pushbutton within the circuit.
11. Still using the finger tool, click on the rectangle of labeled **ASCII Keyboard Input**. You'll see a light blue
    ellipse circling the rectangle to indicate that it has your keyboard focus.

You'll see a welcome message appear on the screen labeled **ASCII Terminal Output**. If you don't see it, scroll right.
Once you see the `bf> ` prompt, type some Brainf*ck code and hit enter. If your code consumes input, you can type it at
this time.
