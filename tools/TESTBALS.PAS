Program test_bals;

uses crt,GIFLoad;

var
  s: string;

begin
Write('Nom:');
Read(s);
asm
  mov ax,$13
  int 10h
end;

LoadGIF(s,$A000);

repeat until keypressed;

asm
  mov ax,$3
  int 10h
end;

end.