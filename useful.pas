unit useful;

interface


function inttostr(enter: word): string;
Procedure LineH (X, Y, L : Word; C : Byte; address: word);
Function SqrWN (X : Word) : Byte;
Procedure Circle (X, Y, R : Word; C : Byte; address: word);
{Procedure Box (X, Y, L, H : Word; C : Byte; address: word);}

implementation




function inttostr(enter: word): string;
begin
inttostr := (Chr((enter div 10) + 48)) + (Chr((enter - ((enter div 10)*10)) + 48));
end;




Procedure LineH (X, Y, L : Word; C : Byte; address: word); Assembler;
Asm
  Mov   AX, address
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, C
  Mov   CX, L
  CLD
  Rep   STOSB
End;



Function SqrWN (X : Word) : Byte; Assembler; { Yi+1 = (Yi + X/Yi) / 2 }
Asm
  Mov   CX, X
  Push  BP
  Mov   BP, 1
  Mov   BX, CX
  JCXZ  @end2
  Cmp   CX, 0FFFFH
  JNE   @cycle
  Mov   BX, 0FFH
  Jmp   @end2
@cycle:
  Xor   DX, DX
  Mov   AX, CX
  Div   BX
  Add   AX, BX
  Shr   AX, 1
  Mov   DI, SI
  Mov   SI, BX
  Mov   BX, AX
  Inc   BP
  Cmp   BX, SI
  JE    @end
  Cmp   BP, 3
  JC    @cycle
  Cmp   BX, DI
  JNE   @cycle
  Cmp   SI, BX
  JNC   @end
  Mov   BX, SI
@end:
  Mov   AX, BX
  Mul   BX
  Sub   AX, CX
  Neg   AX
  Inc   AX
  Mov   SI, AX
  Inc   BX
  Mov   AX, BX
  Mul   BX
  Sub   AX, CX
  Cmp   AX, SI
  JC    @end2
  Dec   BX
@end2:
  Pop   BP
  Mov   AX, BX
End;


Procedure Circle (X, Y, R : Word; C : Byte; address: word);
Var
  A, B: Word;
begin
  If R = 0 then Exit;
  For A := 0 to R do
    Begin
      B := SqrWN(Sqr(R)-Sqr(A));
      LineH (X-B, Y-A, 1+B shl 1, C, address);
      LineH (X-B, Y+A, 1+B shl 1, C, address)
    End
End;

Procedure Box (X, Y, L, H : Word; C : Byte; address: word); assembler;
    Asm
      Mov   AX, address
      Mov   ES, AX
      Mov   DI, X
      Mov   BX, Y
      ShL   BX, 6
      Add   DI, BX
      ShL   BX, 2
      Add   DI, BX
      CLD
      Mov   BX, L
      Mov   DX, H
      Mov   AL, C
@1:
      Push  DI
      Mov   CX, BX
      Rep   STOSB
      Pop   DI
      Add   DI, 320
      Dec   DX
      JNZ   @1
    End;




begin

end.