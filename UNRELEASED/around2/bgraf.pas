unit bgraf;

interface

uses graf,bTypes;

  Procedure DrawScene(mapa : PTmapa; baloos : PTAbaloos; back, sprites, dest : word);


implementation

Procedure DrawMap(mapa : PTmapa; orig, dest : word);
var i,j : byte;
begin
For i := 0+mapa^.x to 39+mapa^.x do
  For j := 0+mapa^.y to 24+mapa^.y do
    If mapa^.tiles[i,j] <> 0 then PutSprite(orig,((mapa^.layout shl 3)*320)+(mapa^.tiles[i,j] shl 3),dest,8,8,i shl 3,j shl 3);
end;

Procedure DrawBaloos(Xoff,Yoff: byte; baloos : PTAbaloos; orig, dest : word);
var i: byte;
begin
For i := 0 to 19 do
  begin
  If (baloos^[i].active) and
   ((baloos^[i].x shr 3)-Xoff >= 0) and ((baloos^[i].x shr 3)-Xoff <= 39) and
   ((baloos^[i].y shr 3)-Yoff >= 0) and ((baloos^[i].y shr 3)-Yoff <= 24) then
    PutSprite(orig,
    ((baloos^[i].o shl 3)*320)+((baloos^[i].mode+baloos^[i].anim) shl 3),
    dest,8,8,baloos^[i].x-(Xoff shl 3),baloos^[i].y-(Yoff shl 3));
  end;
end;

procedure DrawMarcador(marcador : PTmarcador);
begin

end;


Procedure DrawScene(mapa : PTmapa; baloos : PTAbaloos; back, sprites, dest : word);
begin
Flip(back,dest);
DrawMap(mapa,sprites,dest);
DrawBaloos(mapa^.x,mapa^.y,baloos,sprites,dest);
DrawMarcador(marcador : PTmarcador);

waitretrace;
flip(dest,VGA);
end;



begin
end.