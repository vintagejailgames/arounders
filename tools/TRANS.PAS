program transf;

uses crt;


type old_tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..5] of byte;
  tile                             : array[0..19,0..9] of byte;
end;

type new_tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..6] of byte;
  tile                             : array[0..19,0..9] of byte;
end;

var
  level  : old_tipolevel;
  nlevel : new_tipolevel;
  f,g    : file;
  i,j,k  : byte;
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
  Writeln('Arounders Easy Transformeitor');
  Writeln('=============================');
  Writeln;

For i := 1 to 25 do
  begin
  nom := '..\dev\lev\level'+inttostr(i)+'.lev';
  Assign(g,nom);
  reset(g,sizeof(level));
  blockread(g,level,1);
  close(g);

nlevel.layout := level.layout;
nlevel.bmpfondo := level.bmpfondo;
nlevel.orient := level.orient;
nlevel.num := level.num;
nlevel.need := level.need;
For j := 0 to 6 do nlevel.p1[j] := level.p1[j];
For j := 0 to 9 do
  For k := 0 to 19 do
    nlevel.tile[k,j] := level.tile[k,j];

  Assign(f,nom);
  rewrite(f,sizeof(nlevel));
  Write('Transformant ',nom);
  blockwrite(f,nlevel,1);
  Writeln('  OK.');
  close(f);
  end;

Writeln;
Writeln('Tots els arxius han sigut transformats');

end.
