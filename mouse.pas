UNIT MOUSE;

INTERFACE

FUNCTION  MouseReset: BOOLEAN;
PROCEDURE InitMouse;
FUNCTION  EndMouse: BOOLEAN;
PROCEDURE SetMouse(X, Y: WORD);
PROCEDURE HBMouse(Max, Min: WORD);
PROCEDURE VBMouse(Max, Min: WORD);
PROCEDURE GetMouse(VAR X, Y: WORD; VAR B1, B2, B3: BOOLEAN);

IMPLEMENTATION

Uses Dos;

FUNCTION MouseReset: BOOLEAN; ASSEMBLER;

ASM
  MOV AX, 00h
  INT 33h
END;

PROCEDURE InitMouse; ASSEMBLER;

ASM
  MOV AX, 20h
  INT 33h
END;

FUNCTION EndMouse: BOOLEAN;


VAR
  R: REGISTERS;

BEGIN
  R.AX := $1F;
  Intr($33, R);
  EndMouse := (R.AX AND $001F) = $001F;
END;

PROCEDURE SetMouse(X, Y: WORD); ASSEMBLER;

ASM
  MOV AX, 04h
  MOV CX, X
  MOV DX, Y
  INT 33h
END;

PROCEDURE HBMouse(Max, Min: WORD); ASSEMBLER;

ASM
  MOV AX, 07h
  MOV CX, Max
  MOV DX, Min
  INT 33h
END;

PROCEDURE VBMouse(Max, Min: WORD); ASSEMBLER;

ASM
  MOV AX, 08h
  MOV CX, Max
  MOV DX, Min
  INT 33h
END;

PROCEDURE GetMouse(VAR X, Y: WORD; VAR B1, B2, B3: BOOLEAN);

VAR
  R: REGISTERS;

BEGIN
  R.AX := 3;
  Intr($33, R);
  X := R.CX;
  Y := R.DX;
  B1 := (R.BX AND $01) = $01; { Left button   }
  B2 := (R.BX AND $04) = $04; { Middle button }
  B3 := (R.BX AND $02) = $02; { Right button  }
END;

END.