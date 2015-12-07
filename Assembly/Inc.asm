.org 800h;
JMP (Start);

Hi:
.string "Hi";
.word 0;

PrintHi:
LDI (Hi);
JPZ (EndPrintHi);
STM C02h;
INC (PrintHi);
JMP (PrintHi);

EndPrintHi:
RET;

Start:
CALL (PrintHi);

EndLoop:
JMP (EndLoop);