Program palet;

uses crt,graf,gifload;

var
  Pantalla1,Pantalla2,WorkPage : PtrvScreen;
  p1,p2,WP : Word;
  pal : AuxPalette;
  i,j,k,l : word;
  result : boolean;
  r,g,b,ra,ga,ba : byte;

Procedure advise;
begin
sound(440); delay(50); nosound;
end;

Procedure pintapal;
var col :byte;
begin
col := 0;
For k := 1 to 16 do
  For l := 1 to 16 do
    begin
    PutPixel(l,k,col,WP);
    inc(col);
    end;
flip(WP,VGA);
end;


begin
InitGraph;
InitVirtual(Pantalla1,p1);
InitVirtual(Pantalla2,p2);
InitVirtual(WorkPage,WP);

LoadGIF('intro/p1a.gif',p1);

StorePalette(pal);

  pintapal;
repeat until keypressed;

For i := 0 to 15 do
begin
getrgb(i,r,g,b);
ra := (63-r) div 16;
ga := (63-g) div 16;
ba := (63-b) div 16;

For j := 0 to 15 do
  begin
  setrgb(j*16+i,r+(ra*j),g+(ga*j),b+(ba*j));
  If j = 15 then
    setrgb(j*16+i,63,63,63);

  pintapal;
  delay(100);
  end;
end;

StorePalette(pal);

savepalette('intro/pal1.pal',pal);



EndVirtual(Pantalla1);
EndVirtual(Pantalla2);
EndVirtual(WorkPage);
EndGraph;

end.