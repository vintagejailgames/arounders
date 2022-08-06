program lleva_bytes;

uses crt;

var
   f,g : file of byte;
   i,j : byte;
   num : integer;
   s   : string;
begin
clrscr;

Writeln('Lleva-Bytes v0.1');
Writeln('================');
Writeln;
Write('Fitxer: ');Readln(s);
Write('Nombre de bytes a llevar: '); Readln(num);

assign(g,s);

assign(f,'musX.bal');

rewrite(f);
reset(g);

Seek(g,num);

repeat
  read(g,i); Write(f,i);
until EOF(g);

close(g);
close(f);

end.