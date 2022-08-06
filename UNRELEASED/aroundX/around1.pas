unit around1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DXSprite, ExtCtrls, DXClass, DXInput;

type
  TForm1 = class(TDXForm)
    SpEngine: TDXSpriteEngine;
    DXDraw1: TDXDraw;
    Images: TDXImageList;
    time: TDXTimer;
    MiscPics: TDXImageList;
    Controls: TDXInput;
    tiles: TDXImageList;
    procedure FormCreate(Sender: TObject);
    procedure DXDraw1DblClick(Sender: TObject);
    procedure DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure timeTimer(Sender: TObject; LagCount: Integer);
    procedure DXDraw1Initialize(Sender: TObject);
    procedure DXDraw1Finalize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  x_coord : integer;
  Clicked : boolean;
  selected: TSprite;

implementation

{$R *.DFM}

type
  Ratoli = class(TImageSprite)
    private
    protected
      procedure DoMove(MoveCount: Integer); override;
      procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
      procedure DoDraw; override;
    public
      constructor create(AParent: TSprite); override;
    end;

  Selection = class(TImageSprite)
    private
    protected
      procedure DoMove(MoveCount: Integer); override;
    public
      constructor create(AParent: TSprite); override;
    end;

  TArounder = class(TImageSprite)
    private
      action : byte;
      goX : word;
      selected : boolean;
    protected
      procedure DoMove(MoveCount: Integer); override;
    public
      constructor create(AParent: TSprite); override;
  end;

  Background = class(TBackgroundSprite)
  private
    FSpeed: Double;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  end;

// Implementació de Ratoli

constructor Ratoli.create(AParent:TSprite);
begin
inherited create(AParent);
selected := nil;
z := 2;
x := controls.Mouse.cursorpos.x;
y := controls.Mouse.cursorpos.y;
image := Form1.MiscPics.items[0];
width := image.width;
height := image.height;
AnimCount := 1;
AnimLooped := True;
AnimStart := 0;
AnimPos := 0;
AnimSpeed := 8/1000;
end;

procedure Ratoli.DoMove(MoveCount: Integer);
begin
inherited DoMove(MoveCount);
x := controls.Mouse.cursorpos.x - Engine.X;
y := controls.Mouse.cursorpos.y - Engine.Y;
collision;
end;

procedure ratoli.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
Form1.Controls.Update;
If (Sprite is TArounder) then
  begin
  AnimCount := 4;
  If (Form1.controls.Mouse.Buttons[0]) and (not TArounder(Sprite).Selected) then
    begin
    clicked := False;
    If selected <> nil then TArounder(Selected).Selected := False;
    TArounder(Sprite).Selected := True;
    Selected := Sprite;
    end;
  end else AnimCount := 1;
done := False;
end;

procedure ratoli.DoDraw;
begin
inherited DoDraw;
If not collisioned then AnimCount := 1;
end;

var
  Raton : Ratoli;

// Implementació de Selection

constructor Selection.create(AParent:TSprite);
begin
inherited create(AParent);
z := 1;
image := Form1.MiscPics.items[1];
width := image.width;
height := image.height;
AnimCount := 3;
AnimLooped := True;
AnimStart := 0;
AnimPos := 0;
AnimSpeed := 8/1000;
end;

procedure Selection.DoMove(MoveCount: Integer);
begin
inherited DoMove(MoveCount);
If selected <> nil then
  begin
  x := selected.x-1;
  y := selected.y-1;
  end;
end;

// Implementació de TArounder

constructor TArounder.create(AParent:TSprite);
begin
inherited create(AParent);
action := 0;
goX := 0;
selected := False;
x := Random(640);
y := Random(480);
image := Form1.Images.items[0];
width := image.width;
height := image.height;
//image.PatternCount := 6;
//image.PatternWidth := 16;
//image.PatternHeight := 16;
AnimCount := 1;
AnimLooped := True;
AnimStart := 0;
AnimPos := 0;
AnimSpeed := 8/1000;
end;

procedure TArounder.DoMove(MoveCount: Integer);
begin
inherited DoMove(MoveCount);
case action of
0:
  begin
  If selected and clicked then
    begin
    clicked := False;
    GoX := x_coord - Round(Engine.X);
    Action := 1;
    AnimCount := 4;
    AnimStart := 2;
    AnimPos := 0;
    AnimSpeed := 8/1000;
    end;
  end;

1:
  begin
//  If preparing
  If x < goX then x:=x+1;
  if x > goX then x:=x-1;
  If x = goX then
    begin
    action := 0;
    AnimCount := 1;
    AnimLooped := True;
    AnimStart := 0;
    AnimPos := 0;
    AnimSpeed := 8/1000;
    end;
  end;

end;
end;

{ Implementació de BackGround }

procedure Background.DoMove(MoveCount: Integer);
begin
inherited DoMove(MoveCount);
If (controls.Mouse.cursorpos.x > 630) and (Engine.X>-320) then
  Engine.X := Engine.X - MoveCount*(60/1000)*FSpeed;
If (controls.Mouse.cursorpos.x < 10)  and (Engine.X<0) then
Engine.X := Engine.X + MoveCount*(60/1000)*FSpeed;

If (controls.Mouse.cursorpos.y > 470) and (Engine.Y>-240) then
  Engine.Y := Engine.Y - MoveCount*(60/1000)*FSpeed;
If (controls.Mouse.cursorpos.y < 10)  and (Engine.Y<0) then
Engine.Y := Engine.Y + MoveCount*(60/1000)*FSpeed;
Collision;
end;

procedure Background.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
If CollisionMap[0,0] = True then
  Engine.X := 0;
If (sprite is TArounder) then
  Engine.X := 0;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i,j: byte;
begin
Randomize;
DXDraw1.cursor := crNone;
Images.items.LoadFromFile('c:\ar1d.dxg');
Tiles.items.LoadFromFile('tiles1.dxg');
Raton := Ratoli.create(SpEngine.engine);
For i := 1 to 10 do
  TArounder.create(SpEngine.engine);

Selection.create(SpEngine.engine);

  with Background.Create(SpEngine.Engine) do
  begin
    SetMapSize(40, 24);
    Image := Tiles.Items[0];
    Y := 0;
    X := 0;
    Z := -13;
    Width := 18;
    FSpeed := 4;
    Tile := False; //True;
    Collisioned := True;


    for i:=0 to MapHeight-1 do
      for j:=0 to MapWidth-1 do
      begin
        Chips[j, i] := 1;
        CollisionMap[i,j] := False;
      end;
        Chips[20,1] := 2;
    CollisionMap[20,1] := True;
  end;

end;


procedure TForm1.DXDraw1DblClick(Sender: TObject);
begin
Form1.Close;
end;

procedure TForm1.DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
x_coord := X;
clicked := True;
end;

procedure TForm1.timeTimer(Sender: TObject; LagCount: Integer);
begin
If not DXDraw1.CanDraw then exit;

Form1.controls.update;

DXDraw1.Surface.fill(0);
SpEngine.Move(LagCount);
SpEngine.Draw;
MiscPics.Items[2].DrawAlpha(DXDraw1.Surface,Rect(10,10,58,58),0,32);
DXDraw1.Flip;
end;

procedure TForm1.DXDraw1Initialize(Sender: TObject);
begin
Time.Enabled := True;
end;

procedure TForm1.DXDraw1Finalize(Sender: TObject);
begin
Time.Enabled := False;
end;

end.
