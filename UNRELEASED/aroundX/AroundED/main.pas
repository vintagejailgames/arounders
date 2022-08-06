unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, DXSprite, DXDraws;

type
  TForm1 = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    DXDraw1: TDXDraw;
    StatusBar1: TStatusBar;
    Tiles: TDXImageList;
    SpriteEngine: TDXSpriteEngine;
    Pics: TDXImageList;
    DXDraw2: TDXDraw;
    Tiles2: TDXImageList;
    Pics2: TDXImageList;
    procedure FormCreate(Sender: TObject);
    procedure DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXDraw2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXDraw2RestoreSurface(Sender: TObject);
    procedure DXDraw2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXDraw1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  selected : word;
  Boto: byte;

implementation

{$R *.DFM}

type
  Background = class(TBackgroundSprite)
  private
    FSpeed: Double;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

procedure Background.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(60/1000)*FSpeed;
end;

var
  fondo : background;

procedure TForm1.FormCreate(Sender: TObject);
var i,j : integer;
begin
Tiles.Items.LoadFromFile('..\tiles1.dxg');
Tiles2.Items.LoadFromFile('..\tiles1.dxg');
Fondo := Background.Create(SpriteEngine.Engine);
with Fondo do
  begin
    SetMapSize(40, 24);
    Image := Tiles.Items[0];
    Y := 0;
    X := 0;
    Z := -13;
    FSpeed := 0.5;
    Tile := False;
  end;
for i:=0 to Tiles2.Items[0].PatternCount-1 do
   Tiles2.Items[0].Draw(DXDraw2.Surface,(i mod 4)*32,(i div 4)*32,i);
DXDraw2.Flip;
end;

procedure TForm1.DXDraw1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
If button = mbLeft then boto := 1;
If button = mbRight then boto := 2;
DXDraw1.Surface.Fill(0);
//If Boto = 1 then Fondo.Chips[(X div 32),(Y div 32)] := selected;
//If Boto = 2 then Fondo.Chips[(X div 32),(Y div 32)] := 0;
If Boto = 1 then Fondo.Chips[((X-Round(SpriteEngine.Engine.X)) div 32),((Y-Round(SpriteEngine.Engine.Y)) div 32)] := selected;
If Boto = 2 then Fondo.Chips[((X-Round(SpriteEngine.Engine.X)) div 32),((Y-Round(SpriteEngine.Engine.Y)) div 32)] := 0;
Spriteengine.Draw;
Pics.Items[0].Draw(DXDraw1.Surface,(X div 32)*32,(Y div 32)*32,0);
DXDraw1.Flip;
end;

procedure TForm1.DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
If not DXDraw1.CanDraw then exit;
DXDraw1.Surface.Fill(0);
If Boto = 1 then Fondo.Chips[((X-Round(SpriteEngine.Engine.X)) div 32),((Y-Round(SpriteEngine.Engine.Y)) div 32)] := selected;
If Boto = 2 then Fondo.Chips[((X-Round(SpriteEngine.Engine.X)) div 32),((Y-Round(SpriteEngine.Engine.Y)) div 32)] := 0;
Spriteengine.Draw;
Pics.Items[0].Draw(DXDraw1.Surface,(X div 32)*32,(Y div 32)*32,0);
DXDraw1.Flip;
end;

procedure TForm1.DXDraw1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Boto := 0;
end;

procedure TForm1.DXDraw2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i:integer;
begin
If not DXDraw2.CanDraw then exit;
DXDraw2.Surface.Fill(DXDraw2.Surface.ColorMatch(clSilver));
for i:=0 to Tiles2.Items[0].PatternCount-1 do
   Tiles2.Items[0].Draw(DXDraw2.Surface,(i mod 4)*32,(i div 4)*32,i);
Pics2.Items[0].Draw(DXDraw2.Surface,(selected mod 4)*32,(selected div 4)*32,0);
DXDraw2.Flip;
end;

procedure TForm1.DXDraw2RestoreSurface(Sender: TObject);
var i : integer;
begin
DXDraw2.Surface.Fill(DXDraw2.Surface.ColorMatch(clSilver));
for i:=0 to Tiles2.Items[0].PatternCount-1 do
   Tiles2.Items[0].Draw(DXDraw2.Surface,(i mod 4)*32,(i div 4)*32,i);
Pics2.Items[0].Draw(DXDraw2.Surface,(selected mod 4)*32,(selected div 4)*32,0);
DXDraw2.Flip;
end;

procedure TForm1.DXDraw2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
selected := ((Y div 32)*4)+(X div 32);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
If (Key = 39) and (SpriteEngine.Engine.X > -320) then SpriteEngine.Engine.X := SpriteEngine.Engine.X - 32;
If (Key = 40) and (SpriteEngine.Engine.Y > -240) then SpriteEngine.Engine.Y := SpriteEngine.Engine.Y - 32;
If (Key = 37) and (SpriteEngine.Engine.X <    0) then SpriteEngine.Engine.X := SpriteEngine.Engine.X + 32;
If (Key = 38) and (SpriteEngine.Engine.Y <    0) then SpriteEngine.Engine.Y := SpriteEngine.Engine.Y + 32;
Key := 0;
DXDraw1.Surface.Fill(0);
Spriteengine.Draw;
//Pics.Items[0].Draw(DXDraw1.Surface,(X div 32)*32,(Y div 32)*32,0);
DXDraw1.Flip;
end;

end.
