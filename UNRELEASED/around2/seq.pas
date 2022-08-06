Program Seq;

uses crt,graf,gifload;

var
  Pantalla1,Pantalla2,lletres,WorkPage : PtrvScreen;
  p1,p2,LL,WP : Word;
  pal : AuxPalette;
  i,j,contador : word;
  result : boolean;

Procedure pintapal;
var col,k,l :byte;
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

Procedure advise;
begin
sound(440); delay(50); nosound;
end;

Procedure DrawPantalla(mov : word);
begin
If mov = 0 then
  begin
  flip(p1,WP);
  exit;
  end;
If mov = 320 then
  begin
  flip(p2,WP);
  exit;
  end;
PutBlocR(p1, mov, WP, 320-mov, 200, 0      , 0);
PutBlocR(p2, 0  , WP, mov    , 200, 320-mov, 0);
end;

Procedure banner(time,offset,ample,alt,x,y:word);
begin
  If (contador < time) or (contador > time+110) then exit;
  AlphaSprite(LL,offset,WP,ample,alt,x,y,j*16);
  If (contador < time+20) and (j < 15) then inc(j);
  If (contador > time+90) and (j >  0) then dec(j);
end;


begin
InitGraph;
InitVirtual(Pantalla1,p1);
InitVirtual(Pantalla2,p2);
InitVirtual(lletres,LL);
InitVirtual(WorkPage,WP);

cls(0,p1);
LoadGIF('intro/lletres.gif',LL);
LoadGIF('intro/p1a.gif',p1);
LoadGIF('intro/p1b.gif',p2);
LoadPalette('intro/pal1.pal',pal);
flip(p1,vga);


RestorePalette(pal);
blackout;

contador := 0;
i := 0;
j := 0;
delay(1000);
repeat
If contador = 300 then
  begin
  i := 0;
  LoadGIF('intro/p2a.gif',p1);
  LoadGIF('intro/p2b.gif',p2);
  end;

If (contador > 300) and (contador < 440) then
  begin
  If contador < 364 then fadeinstep(pal);
  DrawPantalla(i);
  inc(i);
  end;

If (contador <= 300) then
  begin
  If contador < 64 then fadeinstep(pal);
  If contador > 266 then fadeoutstep;
  DrawPantalla(i);
  inc(i);
  end;

  banner(50,0,144,22,88,89);

  banner(160,7040,188,22,66,89);

  banner(310,14080,110,46,105,77);

If (contador > 440) then

  begin
  If (j < 63) then inc(j);
  setrgb(15,j,j,j);
  end;

flip(WP,VGA);
delay(50);
inc(contador);
until (contador = 600) or (keypressed);

EndVirtual(Pantalla1);
EndVirtual(Pantalla2);
EndVirtual(lletres);
EndVirtual(WorkPage);
EndGraph;

end.     { 144,22 }