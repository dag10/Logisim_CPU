			assemblyOutput.text += "GetInput:\n";
			assemblyOutput.text += "JMP (GetInputInit);\n";
			assemblyOutput.text += "GetInputRet:\n";
			assemblyOutput.text += ".word 0000h;\n";
			assemblyOutput.text += "GetInput_lengthTyped:\n";
			assemblyOutput.text += ".word 0000h; \n";
			assemblyOutput.text += "GetInput_length:\n";
			assemblyOutput.text += ".word 0000h;\n";
			assemblyOutput.text += "GetInput_PlainStore:\n";
			assemblyOutput.text += ".word a000h;\n";
			assemblyOutput.text += "GetInput_tempChar:\n";
			assemblyOutput.text += ".word 0000h;\n";
			assemblyOutput.text += "GetInput_Two:\n";
			assemblyOutput.text += ".word 2;\n";
			assemblyOutput.text += "GetInputInit:\n";
			assemblyOutput.text += "POP;\n";
			assemblyOutput.text += "STM (GetInputRet);\n";
			assemblyOutput.text += "POP;\n";
			assemblyOutput.text += "STM (GetInput_length);\n";
			assemblyOutput.text += "POP;\n";
			assemblyOutput.text += "ADD (GetInput_PlainStore);\n";
			assemblyOutput.text += "STM (GetInputStoreIndex);\n";
			assemblyOutput.text += "STM (GetInputStoreIndex2);\n";
			assemblyOutput.text += "LDI 0;\n";
			assemblyOutput.text += "STM (GetInput_lengthTyped);\n";
			assemblyOutput.text += "GetInputLoop:\n";
			assemblyOutput.text += "LDM (Keyboard);\n";
			assemblyOutput.text += "JPZ (GetInputLoop);\n";
			assemblyOutput.text += "STM (GetInput_tempChar);\n";
			assemblyOutput.text += "XOR (KEY_Enter);\n";
			assemblyOutput.text += "JPZ (GetInputDone);\n";
			assemblyOutput.text += "LDM (GetInput_tempChar);\n";
			assemblyOutput.text += "XOR (KEY_Backspace);\n";
			assemblyOutput.text += "JPZ (GetInputBackspace);\n";
			assemblyOutput.text += "JMP (GetInputSkipBackspace);\n";
			assemblyOutput.text += "GetInputBackspace:\n";
			assemblyOutput.text += "LDM (GetInput_lengthTyped);\n";
			assemblyOutput.text += "JPZ (GetInputLoop);\n";
			assemblyOutput.text += "LDM (GetInput_length);\n";
			assemblyOutput.text += "ADD (One);\n";
			assemblyOutput.text += "STM (GetInput_length);\n";
			assemblyOutput.text += "LDM (GetInputStoreIndex);\n";
			assemblyOutput.text += "SUB (One);\n";
			assemblyOutput.text += "STM (GetInputStoreIndex);\n";
			assemblyOutput.text += "STM (GetInputStoreIndex2);\n";
			assemblyOutput.text += "LDM (GetInput_lengthTyped);\n";
			assemblyOutput.text += "SUB (One);\n";
			assemblyOutput.text += "STM (GetInput_lengthTyped);\n";
			assemblyOutput.text += "LDM (KEY_Backspace);\n";
			assemblyOutput.text += "STM (Display);\n";
			assemblyOutput.text += "LDI 20h;\n";
			assemblyOutput.text += "STM (Display);\n";
			assemblyOutput.text += "LDM (KEY_Backspace);\n";
			assemblyOutput.text += "STM (Display);\n";
			assemblyOutput.text += "LDI 0;\n";
			assemblyOutput.text += "GetInputStoreIndex2:\n";
			assemblyOutput.text += "STM 000h;\n";
			assemblyOutput.text += "JMP (GetInputLoop);\n";
			assemblyOutput.text += "GetInputSkipBackspace:\n";
			assemblyOutput.text += "DEC (GetInput_length);\n";
			assemblyOutput.text += "JPZ (GetInputLoop);\n";
			assemblyOutput.text += "JPM (GetInputLoop);\n";
			assemblyOutput.text += "LDM (GetInput_tempChar);\n";
			assemblyOutput.text += "GetInputStoreIndex:\n";
			assemblyOutput.text += "STM 000h;\n";
			assemblyOutput.text += "STM (Display);\n";
			assemblyOutput.text += "INC (GetInputStoreIndex);\n";
			assemblyOutput.text += "STM (GetInputStoreIndex2);\n";
			assemblyOutput.text += "INC (GetInput_lengthTyped);\n";
			assemblyOutput.text += "JMP (GetInputLoop);\n";
			assemblyOutput.text += "GetInputDone:\n";
			assemblyOutput.text += "JPI (GetInputRet);\n";
			
;	____________________________________________________________________________________________________________________________________
			
.org 000h;
.map Display, C00h;
.map Keyboard, C00h;
JMP (main);
Buffer:
.string "---------------";
PrintLine:
JMP (PrintLineInit);
PrintLineRet:
.word 0000h;
OrigPrintLineLoad:
.word 9000h;
OrigPrintLineJump:
.word b000h;
PrintLineInit:
POP;
STM (PrintLineRet);
POP;
ADD (OrigPrintLineLoad);
STM (PrintLineLoop);
PrintLineLoop:
LDM 000h;
JPZ (PrintLineDone);
STM (Display);
INC (PrintLineLoop);
JMP (PrintLineLoop);
PrintLineDone:
LDI 13;
STM (Display);
JPI (PrintLineRet);
GetInput:
JMP (GetInputInit);
GetInputRet:
.word 0000h;
GetInput_lengthTyped:
.word 0000h; 
GetInput_length:
.word 0000h;
GetInput_PlainStore:
.word a000h;
GetInput_tempChar:
.word 0000h;
GetInput_Two:
.word 2;
GetInputInit:
POP;
STM (GetInputRet);
POP;
STM (GetInput_length);
POP;
ADD (GetInput_PlainStore);
STM (GetInputStoreIndex);
STM (GetInputStoreIndex2);
LDI 0;
STM (GetInput_lengthTyped);
GetInputLoop:
LDM (Keyboard);
JPZ (GetInputLoop);
STM (GetInput_tempChar);
XOR (KEY_Enter);
JPZ (GetInputDone);
LDM (GetInput_tempChar);
XOR (KEY_Backspace);
JPZ (GetInputBackspace);
JMP (GetInputSkipBackspace);
GetInputBackspace:
LDM (GetInput_lengthTyped);
JPZ (GetInputLoop);
LDM (GetInput_length);
ADD (One);
STM (GetInput_length);
LDM (GetInputStoreIndex);
SUB (One);
STM (GetInputStoreIndex);
STM (GetInputStoreIndex2);
LDM (GetInput_lengthTyped);
SUB (One);
STM (GetInput_lengthTyped);
LDM (KEY_Backspace);
STM (Display);
LDI 20h;
STM (Display);
LDM (KEY_Backspace);
STM (Display);
LDI 0;
GetInputStoreIndex2:
STM 000h;
JMP (GetInputLoop);
GetInputSkipBackspace:
DEC (GetInput_length);
JPZ (GetInputLoop);
JPM (GetInputLoop);
LDM (GetInput_tempChar);
GetInputStoreIndex:
STM 000h;
STM (Display);
INC (GetInputStoreIndex);
STM (GetInputStoreIndex2);
INC (GetInput_lengthTyped);
JMP (GetInputLoop);
GetInputDone:
JPI (GetInputRet);
KEY_Enter:
.word 13; Enter key
KEY_Backspace:
.word 8; Backspace key
main:
LDI (Buffer);
PUSH;
LDI 15;
PUSH;
CALL (GetInput);
LDI (Buffer);
PUSH;
CALL (PrintLine);
endloop:
JMP (endloop);




































.org 000h;
.map Display, C00h;
.map Keyboard, C00h;
JMP (main);
Buffer:
.fill 11;
Prompt:
.string "Type something below:";
var0:
.string "> ";
var1:
.string "Goodbye!";
Print:
PrintLine:
JMP (PrintLineInit);
PrintLineRet:
.word 0000h;
OrigPrintLineLoad:
.word 9000h;
OrigPrintLineJump:
.word b000h;
PrintLineInit:
POP;
STM (PrintLineRet);
POP;
ADD (OrigPrintLineLoad);
STM (PrintLineLoop);
PrintLineLoop:
LDM 000h;
JPZ (PrintLineDone);
STM (Display);
INC (PrintLineLoop);
JMP (PrintLineLoop);
PrintLineDone:
JPI (PrintLineRet);
GetInput:
JMP (GetInputInit);
GetInputRet:
.word 0000h;
GetInput_lengthTyped:
.word 0000h; 
GetInput_length:
.word 0000h;
GetInput_PlainStore:
.word a000h;
GetInput_tempChar:
.word 0000h;
GetInput_Two:
.word 2;
GetInputInit:
POP;
STM (GetInputRet);
POP;
STM (GetInput_length);
POP;
ADD (GetInput_PlainStore);
STM (GetInputStoreIndex);
STM (GetInputStoreIndex2);
LDI 0;
STM (GetInput_lengthTyped);
GetInputLoop:
LDM (Keyboard);
JPZ (GetInputLoop);
STM (GetInput_tempChar);
XOR (KEY_Enter);
JPZ (GetInputDone);
LDM (GetInput_tempChar);
XOR (KEY_Backspace);
JPZ (GetInputBackspace);
JMP (GetInputSkipBackspace);
GetInputBackspace:
LDM (GetInput_lengthTyped);
JPZ (GetInputLoop);
LDM (GetInput_length);
ADD (One);
STM (GetInput_length);
LDM (GetInputStoreIndex);
SUB (One);
STM (GetInputStoreIndex);
STM (GetInputStoreIndex2);
LDM (GetInput_lengthTyped);
SUB (One);
STM (GetInput_lengthTyped);
LDM (KEY_Backspace);
STM (Display);
LDI 20h;
STM (Display);
LDM (KEY_Backspace);
STM (Display);
LDI 0;
GetInputStoreIndex2:
STM 000h;
JMP (GetInputLoop);
GetInputSkipBackspace:
DEC (GetInput_length);
JPZ (GetInputLoop);
JPM (GetInputLoop);
LDM (GetInput_tempChar);
GetInputStoreIndex:
STM 000h;
STM (Display);
INC (GetInputStoreIndex);
STM (GetInputStoreIndex2);
INC (GetInput_lengthTyped);
JMP (GetInputLoop);
GetInputDone:
LDI 13;
STM (Display);
JPI (GetInputRet);
Pause:
JMP (PauseInit);
PauseRet:
.word 0000h;
Pause_text:
.string "Press any key to continue . . . ";
PauseInit:
POP;
STM (PauseRet);
LDI (Pause_text);
PUSH;
CALL (Print);
PauseLoop:
LDM (Keyboard);
JPZ (PauseLoop);
PauseDone:
LDI 13;
STM (Display);
JPI (PauseRet);
KEY_Enter:
.word 13; Enter key
KEY_Backspace:
.word 8; Backspace key

	main:
	
		;Printline Prompt
		LDI (Prompt);
		PUSH;
		CALL (PrintLine);
		LDI 13;
		STM (Display);
		
		;Print "> "
		LDI (var0);
		PUSH;
		CALL (PrintLine);
		
		;GetLine Buffer
		LDI (Buffer);
		PUSH;
		LDI 11;
		PUSH;
		CALL (GetInput);
		
		;PrintLine Buffer
		LDI (Buffer);
		PUSH;
		CALL (PrintLine);
		LDI 13;
		STM (Display);
		
		;Pause
		PUSH;
		CALL (Pause);
		POP;
		
		;Printline "Goodbye!"
		LDI (var1);
		PUSH;
		CALL (PrintLine);
		
		;Pause
		PUSH;
		CALL (Pause);
		POP;
		
	endloop:
		.word 0000h;

		
		;///////////////////////////////////////////
		
.org 000h;
.map Display, C00h;
.map Keyboard, C00h;
JMP (main);
var0:
.mstring "Hello World!";
.word 0000h;
Print:
PrintLine:
JMP (PrintLineInit);
PrintLineRet:
.word 0000h;
OrigPrintLineLoad:
.word 9000h;
OrigPrintLineJump:
.word b000h;
PrintLineInit:
POP;
STM (PrintLineRet);
POP;
ADD (OrigPrintLineLoad);
STM (PrintLineLoop);
PrintLineLoop:
LDM 000h;
JPZ (PrintLineDone);
STM (Display);
INC (PrintLineLoop);
JMP (PrintLineLoop);
PrintLineDone:
JPI (PrintLineRet);
Pause:
JMP (PauseInit);
PauseRet:
.word 0000h;
Pause_text:
.string "Press any key to continue . . . ";
PauseInit:
POP;
STM (PauseRet);
LDI (Pause_text);
PUSH;
CALL (Print);
PauseLoop:
LDM (Keyboard);
JPZ (PauseLoop);
PauseDone:
LDI 13;
STM (Display);
JPI (PauseRet);
main:
LDI (var0);
PUSH;
CALL (PrintLine);
LDI 13;
STM (Display);
PUSH;
CALL (Pause);
POP;
endloop:
.word 0000h;
One:
.word 1;
PushData:
.word 0000h;
StackReturn:
.word 0000h;
SPush:
LDM (PushData);
PushAddr:
STM 7FFh;
DEC (PushAddr);
DEC (PopAddr);
LDM (PushData);
JPI (StackReturn);
SPop:
INC (PushAddr);
INC (PopAddr);
PopAddr:
LDM 7FFh;
JPI (StackReturn);
RetAddress:
.word 0;
PlainJump:
.word b000h;



