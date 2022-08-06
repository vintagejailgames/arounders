unit bTypes;

interface

type
  Tmapa = record { 4020 bytes }
    x,y,
    layout,
    back,
    total,
    needed,
    orient      : byte;
    initX,
    initY,
    endX,
    endY        : word;
    action      : array[0..6] of byte;
    tiles       : array[0..79,0..49] of byte;
  end;
  PTmapa = ^Tmapa;

  Tbaloo = record { 10 bytes }
    x,y         : word;
    h,o         : byte;
    mode,
    wannabe,
    anim        : byte;
    active      : boolean;
  end;
  TAbaloos = array[0..19] of Tbaloo; { 200 bytes }
  PTAbaloos = ^TAbaloos;

  Tmarcador = record



implementation

begin
end.