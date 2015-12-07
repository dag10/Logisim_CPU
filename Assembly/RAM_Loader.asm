.org 0;
JMP (LoadRamLoader);
	LDM (CodeStart);
	STM 808h;
	JMP (RamLoop);
LoadRamLoader:
	LDM 1h;
	STM 800h;
	LDM 2h;
	STM 801h;
	LDM 3h;
	STM 802h;
	LDI 1;
	STM 803h;
	LDM (End);
	STM 804h;
	JMP 800h;
RamLoop:
	LDM 800h;
	ADD 803h;
	STM 800h;
	LDM 801h;
	ADD 803h;
	STM 801h;
	LDM 804h;
	SUM 803h;
	JPZ 808h;
	JMP 800h;

; PROGRAM STARTS HERE
CodeStart:
.org 808h; 
; PROGRAM VARIABLES
	MyAge:
	.word 14;
; START OF PROGRAM LOGIC
Start:
	StartLoop:
		LDM (MyAge);
		STM c00h;
		JMP (StartLoop);
; END OF PROGRAM
	End: