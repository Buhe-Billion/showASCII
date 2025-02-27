;DESCRIPTION                :The program loops through characters 32 through 255
;                           :and writes a simple "ASCII chart" in a display buffer. The chart
;                           :consists of 8 lines of 32 characters, with the lines not
;                           :continuous in memory.
;
;Architecture               : X86-64
;CPU                        : Intel® Core™2 Duo CPU T6570 @ 2.10GHz × 2
;NASM                       : 2.14.02
;

;------------------------------------------------------------------------------------------------------------------

SECTION .data

GLOBAL CLRHOME, CLRLEN, SYS_WRITE_CALL_VAL, STDOUT_FD, FILLCHR, EOL, RULERSTRING

SYS_WRITE_CALL_VAL EQU 1
STDERR_FD          EQU 2
SYS_READ_CALL_VAL  EQU 0
STDIN_FD           EQU 0
STDOUT_FD          EQU 1
EXIT_SYSCALL       EQU 60
OK_RET_VAL         EQU 0
EOF_VAL						 EQU 0

EOL                EQU 10   ;Linux end-of-line char
FILLCHR            EQU 32   ;Default to ASCII space character
CHRTROW            EQU 2    ;Chart begins 2 lines from the top
CHRTLEN            EQU 32   ;Each chart line shows 32 chars

; This escape sequence will clear the console terminal and place the
; text cursor to the origin (1,1) on virtually all Linux consoles:

CLRHOME            DB  27,"[2J",27,"[01;01H"
CLRLEN             EQU $-CLRHOME

; We use this to display a ruler across the screen.
RULERSTRING        DB  "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
RULERLEN           EQU  $-RULERSTRING

;------------------------------------------------------------------------------------------------------------------

SECTION .bss

COLS               EQU  81         ; Line length + 1 char for EOL
ROWS               EQU  25         ; Number of lines in display
VIDEOBUFFER        RESB COLS*ROWS  ; Buffer size adapts to ROWS & COLS

;------------------------------------------------------------------------------------------------------------------

SECTION .text

GLOBAL _start
EXTERN CLEARTERMINAL, CLEARVID, RULER, SHOW

_start:
MOV RBP,RSP             ;Tis 4 debugging

; Get the console and text display text buffer ready to go:
CALL CLEARTERMINAL      ;Send terminal clear string to console
CALL CLEARVID           ;Init/Clear the video buffer

;Show a 64 character ruler above the table display:
MOV RAX,1               ; Start ruler at display position 1,1
MOV RBX,1
MOV RCX,32              ; Make ruler 32 characters wide
CALL RULER              ; Generate the ruler

; Now let's generate the chart itself:
MOV RDI,VIDEOBUFFER     ; Start with buffer address in RDI
ADD RDI,COLS*CHRTROW    ; Begin table display down CHRTROW lines
MOV RCX,224             ; Show 256 chars minus first 32
MOV AL,32               ; Start with char 32; others won't show

.DOLN:
MOV BL,CHRTLEN          ; Each line will consist of 32 chars
.DOCHAR:
STOSB                   ; Note that there's no REP prefix!
JRCXZ ALLDONE           ; When the full set is printed, quit
INC AL                  ; Bump the character value in AL up by 1
DEC BL                  ; Decrement the line counter by one
LOOPNZ .DOCHAR          ; Go back & do another char until BL goes to 0

ADD RDI,COLS-CHRTLEN    ; Move RDI to start of next line
JMP .DOLN               ; Start display of the next line {Moving up memory}

; Having written all that to the buffer, send buffer to the console:
ALLDONE:
CALL SHOW

EXIT:
MOV RSP,RBP
POP RBP

MOV RAX,EXIT_SYSCALL
MOV RDI,OK_RET_VAL
SYSCALL
