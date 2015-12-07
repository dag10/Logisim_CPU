; Set program origin and jump to start (so as not to execute the constants)
.org 000h
JMP (Start)

; ADDRESSES
	.map InputNumberA, C00h
	.map InputNumberB, C01h
	.map OutputNumber, C00h
	
; VARIABLES
	.map NumberA, 800h
	.map NumberB, 801h
	.map Product, 802h

; CONSTANTS
	One:
		.word 0001h

; PROGRAM
	Start:
	
		; Clear product variable
		LDI 0
		STM (Product)
		
		; Read in the two input numbers and store them in RAM for calculation
		LDM (InputNumberA)
		STM (NumberA)
		LDM (InputNumberB)
		STM (NumberB)
		
		; Begin loop of repeatedly adding NumberB for NumberA times
		LoopStart:
		
			; If NumberA is zero, leave loop
			LDM (NumberA)
			JPZ (LoopEnd)
			
			; Add NumberB to product variable
			LDM (Product)
			ADD (NumberB)
			STM (Product)
			
			; Decrement NumberA
			LDM (NumberA)
			SUB (One)
			STM (NumberA)
			
			; Loop
			JMP (LoopStart)
		
		LoopEnd:
		
			; Write product to output address
			LDM (Product)
			STM (OutputNumber)
			
			; Goto start
			JMP (Start)