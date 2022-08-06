unit objectes;

interface

type
  Tlevel = Object
   private
    baloos_totals,                 { numero total de baloos en pantalla }
    baloos_necessaris,             { numero de baloos que han de sobreviure }
    fondo,                         { fondo de la fase }
    layout,                        { set de tiles/pantalla de la fase }
    orient: byte;                  { orientació inicial dels baloos }
    action : array[0..6] of byte;   { numero de accions }
   public
    procedure carregar(num : byte);
    function get_total : byte;
    function get_need : byte;
    function get_fondo : byte;
    function get_layout : byte;
    function get_orient : byte;
    function get_action(num : byte) : byte;
    procedure inc_action(num : byte; add : integer);
  end;

  Tbaloo = object
   private



implementation

procedure Tlevel.carregar(num : byte);
type tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..6] of byte;
  tile                             : array[0..19,0..9] of byte;
end;

var
  mylevel : tipolevel;
  i,j   : word;
  f     : file of tipolevel;
  temp  : char;
  temp2 : byte;

begin
assign(f,'data\data.bal');
reset(f);
seek(f,num-1);
read(f,mylevel);
close(f);

layout                  := mylevel.layout;
fondo                   := mylevel.bmpfondo;
orient                  := mylevel.orient;
baloos_totals           := mylevel.num;
baloos_necessaris       := mylevel.need;
For i := 0 to 6 do action[i] := mylevel.p1[i];
end;

function Tlevel.get_total: byte;
begin
get_total := baloos_totals;
end;

function Tlevel.get_need: byte;
begin
get_need := baloos_necessaris;
end;

function Tlevel.get_fondo: byte;
begin
get_fondo := fondo;
end;

function Tlevel.get_layout: byte;
begin
get_layout := layout;
end;

function Tlevel.get_orient: byte;
begin
get_orient := orient;
end;

function Tlevel.get_action(num : byte) : byte;
begin
get_action := action[num];
end;

procedure Tlevel.inc_action(num : byte; add : integer);
begin
action[num] := action[num] + add;
end;


begin
end.