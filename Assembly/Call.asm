.org 800h; Program originates in RAM location 800h

; I/O Ports
.map Display, C02h; Terminal display for output
.map Keyboard, C02h; Buffered keyboard for input
.map Port1, C00h; I/O port 1
.map Port2, C01h; I/O port 2

JMP (Start); Skip over data / functions

; PROGRAM DATA
	STRING_Prompt:
		.string "> ";

; PROGRAM FUNCTIONS
	PrintLine:
		JMP (PrintLineInit);
			PrintLineRet:
				.word 0000h; Return Address
			OrigPrintLineLoad:
				.word 9000h; Plain load command
			OrigPrintLineJump:
				.word b000h; Plain jump command
		PrintLineInit:
			POP; Pops return address
			STM (PrintLineRet);
			POP; Pops pointer to string
			ADD (OrigPrintLineLoad);
			STM (PrintLineLoop); Update load command to start at string
		PrintLineLoop:
			LDM 000h; String address to load
			JPZ (PrintLineDone); Return when string is done
			STM (Display); Write to display
			INC (PrintLineLoop); Increment string pointer
			JMP (PrintLineLoop); Loop again
		PrintLineDone:
			LDI 13;
			STM (Display); Add a new line
			JPI (PrintLineRet); Return
	Print:
		JMP (PrintInit);
			PrintRet:
				.word 0000h; Return Address
			OrigPrintLoad:
				.word 9000h; Plain load command
		PrintInit:
			POP; Pops return address
			STM (PrintRet);
			POP; Pops pointer to string
			ADD (OrigPrintLoad);
			STM (PrintLoop); Update load command to start at string
		PrintLoop:
			LDM 000h; String address to load
			JPZ (PrintDone); Return when string is done
			STM (Display); Write to display
			INC (PrintLoop); Increment string pointer
			JMP (PrintLoop); Loop again
		PrintDone:
			JPI (PrintRet); Return
	Boot:
		JMP (BootInit);
			BootRet:
				.word 0000h; Return Address
			Boot_BootMSG:
				.string "Welcome to DrewOS!";
		BootInit:
			POP;
			STM (BootRet);
		BootInitSystem:
			; Do system initiation stuff here
		BootMessage:
			LDI (Boot_BootMSG); Load boot message
			PUSH;
			CALL (PrintLine); Print boot message
		BootDone:
			JPI (BootRet); Return
		

; PROGRAM START
Start:
	CALL (Boot); Initiate system
EndLoop:
	JMP (EndLoop);