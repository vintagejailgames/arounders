program merger;

uses crt;



type tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..6] of byte;
  tile                             : array[0..19,0..9] of byte;
end;

var
  level  : tipolevel;
  f,g    : file;
  i      : byte;
  nom    : string;

function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string;
begin
 Str(I, S);
 IntToStr := S;
end;

begin
  clrscr;
  Writeln('Arounders Easy Anyadeitor');
  Writeln('=========================');
  Writeln;

Assign(f,'..\data\data.bal');
rewrite(f,sizeof(level));

For i := 1 to 30 do
  begin
  nom := '..\dev\lev\level'+inttostr(i)+'.lev';
  Assign(g,nom);
  reset(g,sizeof(level));
  blockread(g,level,1);
  close(g);
  Write('Anyadint ',nom);
  blockwrite(f,level,1);
  Writeln('  OK.');
  end;

close(f);

Writeln;
Writeln('Tots els arxius han sigut anyadits');

end.
