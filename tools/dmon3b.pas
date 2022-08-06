(* Unit DirectMon© *)
(* En compte d'utilitzar llistes utilitzar un vector *)

unit DMON3b;

interface

uses crt;

const
  (* En aquesta adre‡a comen‡a la mem•ria de la VGA *)
  VGA = $a000;

  (* Tamany de la cap‡alera d'un fitxer PCX *)
  PCXHeader = 128;

  (* Tamany d'una paleta de 256 colors *)
  (* 256 colors x (1 Red + 1 Green + 1 Blue) = 256 x 3 = 768 bytes *)
  SizePalette = 768;

type

  PCXType=			{ Tipo PCX }
    record
      flag: byte;		{ si (flag = 10): PCX }
      version: byte;
      encoded: byte;		{ si (encoded = 1): RLE Encoded }
      xmin: word;
      ymin: word;
      xmax: word;
      ymax: word;
    end;

  (* Pantalla virtual del tamany de 320x200 *)
  VScreen = array [1..64000] of byte;
  (* Punter que apunta a aquesta pantalla *)
  PtrVScreen = ^VScreen;

  (* Tipus RGB: guarda valors de Red, Green i Blue d'un color *)
  RGB=
    record
    R,G,B: byte;
    end;

  (* Tipus AuxPaleta: cont‚ una paleta de 256 colors *)
  AuxPalette = array [0..255] of RGB;

  (* Tipus Street Poll per a guardar els words de BackGround *)
  TSP= array [1..4] of word;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{	             TIPUS I PROCEDIMENTS AUXILIARS PER A LES LLISTES             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*
  Element= PtrVScreen;

  ptr= ^node;

  node=
    record
      d: element;			{ pantalla virtual             }
      w: word;				{ word associat                }
      s: ptr					{ punter per a enganxar-ne m‚s }
    end;

  NumberOfVS=
  	record
    	x,y: byte				{ x*y = nombre de pantalles virtuals necess…ries }
    end;

  List=
    record
      p,u,a: ptr;			{ primer node; £ltim node; actual node     }
      VS: NumberOfVS;	{ nombre de pantalles virtuals necess…ries }
    end;
  *)
var
  (* Paleta per defecte de la BIOS *)
  BIOSPal: AuxPalette;

  (* On guardarem la informaci¢ del fitxer PCX que estem carregant *)
  PCX: PCXType;

  (* Tamany de dades del fitxer PCX que estem carregant *)
  SizePCXData: word;

  (* Tamany del fitxer PCX que estem carregant *)
  SizePCX: longint;

  (* Pantalles Virtuals Per Defecte De DirectMon© i la paraula associada *)
  WorkPage: PtrVScreen;
  WP: word;

  SpritesPage: PtrVScreen;
  SP: word;

  ItemsPage: PtrVScreen;
  IP: word;

  (* Llista per a emmagatzemar el fons *)
  {BackGround: List;}

  (* X Pantalles Virtuals x Y Pantalles Virtuals          *)
  (* AUXXVS i AUXYVS s¢n per a despistar a un procediment *)
  XVS,YVS,AUXXVS,AUXYVS: word;

  (* L¡mits de la c…mera *)
  MAXCameraX,MINCameraX,
  MAXCameraY,MINCameraY: integer;

  (* soluci¢ al Street Poll de les llistes *)
  streetpoll: TSP;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{              PROCEDIMENTS B·SICS PER A L'éS DE DIRECT MON                 }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Inicialitza una pantalla virtual *)
  procedure InitVirtual(var screen: PtrVScreen; var address:word);

  (* Llibera de mem•ria una pantalla virtual *)
  procedure EndVirtual(var screen: PtrVScreen);

  (* Inicia l'entorn gr…fic de Direct Mon *)
  procedure InitDM;

  (* Acaba l'entorn gr…fic de Direct Mon *)
  procedure EndDM;

  (* Espera el retra‡ vertical de la VGA *)
  procedure WaitRetrace;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{              PROCEDIMENTS PER A L'éS DE LA PALETA DE COLORS               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Capta els valors de RGB del color 'index' i els guarda en r, g i b *)
  procedure GetRGB(index: byte; var r,g,b: byte);

  (* Assigna al color 'index' els valors de RGB donats per r, g i b *)
  procedure SetRGB(index: byte; r,g,b: byte);

  (* Guarda la paleta actual en la variable 'paleta' *)
  procedure SavePalette(var palette: AuxPalette);

  (* Estableix la paleta 'paleta' com a paleta actual *)
  procedure RestorePalette(palette: AuxPalette);

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                            ALTRES PROCEDIMENTS                            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Calcula el offset en que est… la coordenada (x,y) *)
  function COffset(x,y: integer): word;

  (* Volca una zona de mem•ria en un altra *)
  procedure Flip(orig,dest: word);

  (* Neteja la pantalla virtual 'address' amb el color 'color' *)
  procedure Cls(color: byte; address: word);

  (* Pinta un pixel en (x,y) del color 'color' en la pantalla 'address' *)
  procedure PutPixel(x,y: word; color: byte; address: word);

  (* Torna el color del pixel (x,y) de la pantalla 'address' *)
  function GetPixel(address: word; x,y: integer): byte;

  (* Pinta un pixel en (x,y) del color 'color' en la pantalla 'zona'
  procedure PutPixelT(x,y: word; color,trans: byte; address: word);  *)

  (* Col.loca sprites amb transparencies *)
  procedure PutSprite(orig,xo,yo,dest,xf,yf,width,height: word);

  (* Col.loca sprites sense transparencies *)
  procedure PutBloc(mem_orig,m_offset,mem_dest,ample,alt,posx,posy:word);

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                 FUNDITS PER A TRANSICIà ENTRE PANTALLES                   }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Realitza un fundit cap a la paleta 'paleta' *)
  procedure FadeIn(palette: AuxPalette);

  (* Realitza un fundit cap al negre *)
  procedure FadeOut;

  (* Realitza un fundit circular des del centre cap a fora *)
  procedure FadeCircleIn(time: word; address: word);

  (* Realitza uns fundits que molen dos ous (m= 1..14 determina la forma *)
  procedure FadeChaos(time: word; m: byte; address: word);

  (* Realitza un fundit que mola un ou *)
  procedure FadeChaos2(time: word; address: word);

  (* Realitza un fundit des de l'esquerra a la dreta *)
  procedure FadeLeftRight(time: word);

  (* Realitza un fundit des de la dreta a l'esquerra *)
  procedure FadeRightLeft(time: word);

  (* Realitza un fundit des de dalt cap a baix *)
  procedure FadeTopBottom(time: word);

  (* Realitza un fundit des de baix cap a dalt *)
  procedure FadeBottomTop(time: word);

  (* Estableix la paleta actual tota negra, no s‚ pa' que val *)
  procedure Blackout;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A FER DIBUIXOS                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Dibuixa una linia *)
  procedure Line(x1,y1,x2,y2: integer; color: byte; address: word);

  (* Fa un rectangle *)
  procedure Rectangle(x1,y1,x2,y2: integer; color: byte; address: word);

  (* Fa un cercle *){ Tret dels tutorials del Denthor Asphixia }
  procedure circle(xo,yo,rad: integer; color: byte; address: word);

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            PROCEDIMENTS PER AL MANIPULAMENT DE FITXERS *.PCX              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

  (* Carrega un fitxer gr…fic en format PCX de m‚s de 320x200 *)
  procedure LoadHugePCX(filename: string);

  (* Carrega un fitxer gr…fic en format PCX de 320x200 *)
  procedure LoadPCX(filename: string; address: word);

  (* Carrega un PCX de 320x200 des d'un arxiu packed d'eixos *)
  procedure LoadPCXP(filename: string; offset: word; address: word);

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A SCROLLS												 	}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

(* Realitza un scroll vertical de la zona1 despla‡ant-la "i" linies down *)
{  procedure VerticalScroll(zona1,zona2: word; i: integer);
  procedure HorizontalScroll(zona1,zona2: word; i: integer);}

  procedure scroll(orig,dest,desp:word);

  (* Mou la c…mera sobre la llista BackGround *)
  procedure Camera(x,y: integer);
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A LES LLISTES  									 	}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*
  procedure CreateList(var ll: List);
  procedure InsertInList(var ll: List; e: Element; w: word);
  {procedure DeleteFromList(var ll: List);}
  function RestoreWordFromList(ll: List): word;
  {function RestoreVScreenFromList(ll: List): element;}
  procedure TopList(var ll: List);
  {procedure BottomList(var ll: List);}
  procedure NextFromList(var ll: List);
  {function IsEmpty(ll: List): boolean;
  function EndOfList(ll: List): boolean;}
  procedure ColocaEnLlista(XVS,YVS: byte);*)

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

implementation

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{              PROCEDIMENTS B·SICS PER A L'éS DE DIRECT MON                 }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure InitDM;
    begin
      asm
      mov ax,$13
      int 10h
      end;
    InitVirtual(WorkPage,WP);
    InitVirtual(SpritesPage,SP);
    InitVirtual(ItemsPage,IP);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure EndDM;
    begin
      asm
      mov ax,$3
      int 10h
      end;
    EndVirtual(WorkPage);
    EndVirtual(SpritesPage);
    EndVirtual(ItemsPage);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure WaitRetrace; assembler;
    label
     l1,l2;

    asm
    mov dx,3dah

      l1:
      	in al,dx
	test al,8		{ and al,08h }
        jne l1			{ jnz l1 }

      l2:
      	in al,dx
        test al,8		{ and al,08h }
        je l2			{ jz l2 }

    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure InitVirtual(var screen: PtrVScreen; var address:word);
    begin
    getmem(screen,64000);
    address:= seg(screen^);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure EndVirtual(var screen: PtrVScreen);
    begin
    If screen <> nil then freemem(screen,64000);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{              PROCEDIMENTS PER A L'éS DE LA PALETA DE COLORS               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure GetRGB(index: byte; var r,g,b: byte);
    begin
    port[$3c7]:= index;
    r:= port[$3c9];
    g:= port[$3c9];
    b:= port[$3c9];
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure SetRGB(index: byte; r,g,b: byte);
    begin
    port[$3c8]:= index;
    port[$3c9]:= r;
    port[$3c9]:= g;
    port[$3c9]:= b;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure SavePalette(var palette: AuxPalette);
    var
      loop: byte;

    begin
    for loop:= 0 to 255 do
      GetRGB(loop,palette[loop].r,palette[loop].g,palette[loop].b);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure RestorePalette(palette: AuxPalette);
    var
      loop: byte;

    begin
    WaitRetrace;
    for loop:= 0 to 255 do
      SetRGB(loop,palette[loop].r,palette[loop].g,palette[loop].b);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeIn(palette: AuxPalette);
    var
      loop1,loop2: byte;
      aux: array [1..3] of byte;

    begin
    for loop1:= 1 to 64 do
      begin
      WaitRetrace;
      for loop2:= 0 to 255 do
	begin
        GetRGB(loop2,aux[1],aux[2],aux[3]);
        if (aux[1] < palette[loop2].r) then inc(aux[1]);
        if (aux[2] < palette[loop2].g) then inc(aux[2]);
        if (aux[3] < palette[loop2].b) then inc(aux[3]);
	SetRGB(loop2,aux[1],aux[2],aux[3]);
        end;
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeOut;
    var
      loop1,loop2: byte;
      aux: array [1..3] of byte;

    begin
    for loop1:= 1 to 64 do
      begin
      WaitRetrace;
      for loop2:= 0 to 255 do
	begin
        GetRGB(loop2,aux[1],aux[2],aux[3]);
        if (aux[1] > 0) then dec(aux[1]);
        if (aux[2] > 0) then dec(aux[2]);
        if (aux[3] > 0) then dec (aux[3]);
        SetRGB(loop2,aux[1],aux[2],aux[3]);
        end;
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeCircleIn(time: word; address: word);
    const
    	{ middle of screen }
      centerX = 319 div 2;
      centerY = 199 div 2;
      { number of circles = sqrt(centerXı + centerYı), rounded up }
      k = 189;
      { compensation in diagonal direction = 1/sqrt(2) }
      adjust = 0.707106781;
      { number of executions of the delay loop }
      n = trunc(k/adjust);

    var
      radqu,x,y,x0,y0,u1,u2,u3,u4,v1,v2,v3,v4: word;
      counter: word;
      ClockTicks: longint absolute $40:$6C;
      t: longint;
      temp,radius: real;

    begin
      t:= ClockTicks;
      counter:= 0;
      temp:= 0.0182*time/n;
      x0:= centerX;
      y0:= centerY;
      { unfortunately, FOR true_radius:=1 TO k STEP 1/adjust isn't possible in TP }
      radius:= 0.0;
      repeat
        radqu:= trunc(sqr(radius));
        for x:= 0 to trunc(radius/sqrt(2)) do {compute octant    }
       	  begin
       	  y:= trunc(sqrt(radqu-sqr(x))); {Pythagorean proposition        }
          u1:= x0-x; v1:= y0-y;          {use axial- and point symmetrie }
          u2:= x0+x; v2:= y0+y;
          u3:= x0-y; v3:= y0-x;
          u4:= x0+y; v4:= y0+x;
          PutPixel(u1,v1,GetPixel(address,u1,v1),VGA);
          PutPixel(u1,v2,GetPixel(address,u1,v2),VGA);
          PutPixel(u2,v1,GetPixel(address,u2,v1),VGA);
          PutPixel(u2,v2,GetPixel(address,u2,v2),VGA);
          PutPixel(u3,v3,GetPixel(address,u3,v3),VGA);
          PutPixel(u3,v4,GetPixel(address,u3,v4),VGA);
          PutPixel(u4,v3,GetPixel(address,u4,v3),VGA);
          PutPixel(u4,v4,GetPixel(address,u4,v4),VGA);
          end;
        radius:= radius+adjust;
        inc(counter);
        while (ClockTicks < t+counter*temp) do begin end;
      until (radius >= k);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeChaos(time: word; m: byte; address: word);
    const
      n = 64000;  {number of screen pixels}
      { e.g., good values are sums of powers of 2 +1 }
      para: array [1..14] of word =
      	(13477,65,337,129,257,513,769,1025,481,4097,5121,177,16385,16897);

    var
      i,k,x,y: word;
      counter: word;
      ClockTicks: longint absolute $40:$6C;
      t: longint;
      temp: real;
      rand: word;

    begin
      t:= ClockTicks;
      counter:= 0;
      rand:= 0;
      if (m < 1) or (m > 14) then m:= 1;
      k:= para[m];
      temp:= 0.0182*time/n;
      for i:= 0 to 65535 do
      	begin
          asm {compute: "x := rand MOD 320" and "y := rand DIV 320" }
          xor dx,dx
          mov ax,rand
          mov bx,319+1
          div bx
	  mov y,ax
          mov x,dx
	  end;
        if (y <= 199) then PutPixel(x,y,GetPixel(address,x,y),VGA);
          asm {compute: rand:=rand*k+1 }
          mov ax,rand
          mul k
          inc ax
          mov rand,ax
          end;
        inc(counter);
        while (ClockTicks < t+counter*temp) do begin end;
        end; {of FOR i}
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeChaos2(time: word; address: word);
    const
      n = 64000;  {number of screen pixels}

    var
      i,x,y: word;
      counter: word;
      ClockTicks: longint absolute $40:$6C;
      t: longint;
      temp: real;
      rand: word;
      m: byte;

    begin
      t:= ClockTicks;
      counter:= 0;
      rand:= 0;
      temp:= 0.0182*time/n;
      for i:= 0 to 65535 do
      	begin
          asm {compute: "x:=rand MOD 320" and "y:=rand DIV 320" }
          xor	dx,dx
          mov ax,rand
          mov bx,319+1
          div bx
	  mov y,ax
          mov x,dx
          end;
        PutPixel(x,y,GetPixel(address,x,y),VGA);
          asm {compute: rand:=(rand+k) MOD n }
            xor	dx,dx
            mov ax,rand
            add ax,39551{k}
	    jnc @normal
            add ax,(65536-n)  {overflow, thus correct it }

            @normal:
              cmp ax,n
              jb @ok
              sub ax,n

            @ok:
              mov rand,ax
          end;
        inc(counter);
        while (ClockTicks < t+counter*temp) do begin end;
        end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeLeftRight(time: word);
    var
      i: integer;

    begin
      for i:= 0 to 319 do
	begin
	Line(i,0,i,199,0,VGA);
        delay(time);
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeRightLeft(time: word);
    var
      i: integer;

    begin
      for i:= 319 downto 0 do
        begin
	Line(i,0,i,199,0,VGA);
        delay(time);
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeTopBottom(time: word);
    var
      i: integer;

    begin
      for i:= 0 to 199 do
	begin
	Line(0,i,319,i,0,VGA);
        delay(time);
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure FadeBottomTop(time: word);
    var
      i: integer;

    begin
      for i:= 199 downto 0 do
	begin
	Line(0,i,319,i,0,VGA);
        delay(time);
      end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure Blackout;
    var
      loop: integer;

    begin
    WaitRetrace;
    for loop:= 0 to 255 do SetRGB(loop,0,0,0);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                            ALTRES PROCEDIMENTS                            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  function COffset(x,y: integer): word;
    var
    offs: word;

    begin
    (*asm
      mov di,x	  	{DI = x        }
      mov dx,y	  	{DX = y        }
      shl dx,8		{DX = 256*y    }
      add di,dx		{DI = 256*y+x  }
      shr dx,2	  	{DX = 64*y     }
      add di,dx		{DI = 320*y+x  }
      mov offs,di       { no s‚ si a‡• est… b‚ }
      end;*)
      COffset:= 320*(y mod 200)+(x mod 320);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure Flip(orig,dest: word); assembler;
    asm
      push ds	    { apilar ds                   }
      mov ax,orig   { ds -> orig                  }
      mov ds,ax     {      "                      }
      xor di,di	    { di -> 0                     }
      mov ax,dest   { es -> dest                  }
      mov es,ax	    {      "                      }
      xor si,si	    { si -> 0                     }
      mov cx,16000  { cx -> 32000                 }{ ¨? }
      db $66
      rep movsw     { mou un word des des di a si }{ ¨? }
      pop ds	    { desapilar ds                }
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure Cls(color: byte; address: word); assembler;
  Asm
    mov ax,address
    mov es,ax
    xor di,di
    mov al,color
    mov ah,al
    mov cx,16000
    db $66
    rep stosw
  End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure PutPixel(x,y: word; color: byte; address: word); Assembler;
  Asm
    Mov   AX, address
    Mov   ES, AX
    Mov   DI, X
    Mov   BX, Y
    ShL   BX, 6
    Add   DI, BX
    ShL   BX, 2
    Add   DI, BX
    Mov   AL, Color
    STOSB
  End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  function GetPixel(address: word; x,y: integer): byte; Assembler;
  Asm
    Mov   AX, address
    Mov   ES, AX
    Mov   DI, X
    Mov   BX, Y
    ShL   BX, 6
    Add   DI, BX
    ShL   BX, 2
    Add   DI, BX
    Mov   AL, ES:[DI]
  End;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*	procedure PutPixelT(x,y: word; color,trans: byte; address: word);
  	begin
    	asm
        mov   ax,address
        mov   es,ax
      end;

      COffset(x,y);

		  asm
	      mov   al,color
  	    xor   al,trans
    	  jnz   @paint

	      inc(di)
  	    jmp @exit

	    @paint:
				mov es:[di],al

			@exit:
  	  end;
    end;   *)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure PutSprite(orig,xo,yo,dest,xf,yf,width,height: word);
    var
      offset1,offset2: word;

    begin
      offset1:= COffset(xo,yo);
      offset2:= COffset(xf,yf);

    	asm
      	push ds

        mov si,offset1
        mov di,offset2

        mov ax,orig
        mov ds,ax

        mov ax,dest
        mov es,ax
        end;

      {offset2:= COffset(xf,yf);}

  	asm
        mov cx,height

        @1:
	  push cx
          push di
          push si

          mov cx,width

        @nou_pixel:
          mov al,ds:[si]
          or al,00h
          jnz @paint
          jmp @new

        @paint:
          mov es:[di],al  { pintar pixel                      }

        @new:
          inc di    	  { augmenta el punter de pantalla    }
          inc si	  { augmenta el punter font           }
          loop @nou_pixel { mentres no siga l'ample continuar }
          pop si          { recuperem l'offset origen         }
          pop di          { recuperem l'offset desti          }
          add si,320      { segent linia orige               }
          add di,320      { segent linia desti               }
          pop cx          { recuperem l'alt                   }
          dec cx          { una linia menys                   }
          cmp cx,0        { Queden linies?                    }
          jnz @1          { Si. Anar a @1                     }
          pop ds
        end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure PutBloc(mem_orig,m_offset,mem_dest,ample,alt,posx,posy:word);
begin
    asm
       push ds;

       mov si,m_offset;

       mov ax,mem_orig;
       mov ds,ax;        {memoria orige}
       mov ax,mem_dest;
       mov es,ax;        {memoria desti}

       mov   di,posx;    {DI = X}
       mov   dx,posy;    {DX = Y}
       shl   dx,8;       {DX = 256*Y}
       add   di,dx;      {DI = 256*Y+BX}
       shr   dx,2;       {DX = 64*Y}
       add   di,dx;      {DI = 320*Y+X}

       mov cx,alt;       {guarde el alt}

   @1: push cx;          {guarde el alt}
       push di;          {guarde el offset desti}
       push si;          {guarde el offset orige}

       mov cx,ample;     {carregue el ample}
       shr cx,2;

       db $66
       rep movsw;        {mentres no siga l'ample continuar}

       pop si;           {recuperem l'offset orige}
       pop di;           {recuperem l'offset desti}
       add si,320;       {segent linia orige}
       add di,320;       {segent linia desti}
       pop cx;           {recuperem l'alt}
       dec cx;           {una linia menys}
       cmp cx,0;         {Queden linies?}
       jnz @1;           {Si.Anar a @1}

       pop ds;
   end;
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A FER DIBUIXOS                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure Line(x1,y1,x2,y2: integer; color: byte; address: word);
    var
      i,deltax,deltay,numpixels,
      d,dinc1,dinc2,
      x,xinc1,xinc2,
      y,yinc1,yinc2: integer;

    begin

    	{ Calculate deltax and deltay for initialisation }
      deltax:= abs(x2-x1);
      deltay:= abs(y2-y1);

      { Initialize all vars based on which is the independent variable }
      if (deltax >= deltay) then
        begin
        { x is independent variable }
        numpixels:= deltax+1;
        d:= (deltay shl 1) - deltax;
        dinc1:= deltay shl 1;
        dinc2:= (deltay-deltax) shl 1;
        xinc1:= 1;
        xinc2:= 1;
        yinc1:= 0;
        yinc2:= 1;
        end
      else
        begin
       	{ y is independent variable }
        numpixels:= deltay+1;
        d:= (deltax shl 1)-deltay;
        dinc1:= deltax shl 1;
        dinc2:= (deltax-deltay) shl 1;
        xinc1:= 0;
        xinc2:= 1;
        yinc1:= 1;
        yinc2:= 1;
        end;

      { Make sure x and y move in the right directions }
      if (x1 > x2) then
        begin
        xinc1:= -xinc1;
        xinc2:= -xinc2;
        end;
      if (y1 > y2) then
        begin
        yinc1:= -yinc1;
        yinc2:= -yinc2;
        end;

      { Start drawing at <x1, y1> }
      x:= x1;
      y:= y1;

      { Draw the pixels }
      for i:= 1 to numpixels do
      	begin
        PutPixel(x,y,color,address);	{ <--- el tema pa fer un fade uapo est… a¡ }
        if (d < 0) then
          begin
          d:= d+dinc1;
          x:= x+xinc1;
          y:= y+yinc1;
          end
        else
          begin
          d:= d+dinc2;
          x:= x+xinc2;
          y:= y+yinc2;
          end;
        end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure Rectangle(x1,y1,x2,y2: integer; color: byte; address: word);
    begin
      Line(x1,y1,x2,y1,color,address);
      Line(x2,y1,x2,y2,color,address);
      Line(x2,y2,x1,y2,color,address);
      Line(x1,y2,x1,y1,color,address);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure circle(xo,yo,rad: integer; color: byte; address: word);
    var
      deg: real;
      x,y: integer;

    begin
    deg:= 0;
    repeat
      x:= round(rad*cos(deg));
      y:= round(rad*sin(deg));
      putpixel(x+xo,y+yo,color,address);
      deg:= deg+0.005;
    until (deg > 6.4)
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            PROCEDIMENTS PER AL MANIPULAMENT DE FITXERS *.PCX              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  function QuinaPantalla(XVS: byte; x,y: integer): byte;
    begin
      QuinaPantalla:= (XVS*(y div 200))+((x div 320)+1);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure LoadHeader(var file_in: file; var XVS,YVS: word);
  { llegim directament els 128 bytes de la cap‡alera per a optimitzar }
  var
    Header: array [1..128] of byte;

    begin
      blockread(file_in,Header,PCXHeader);
      pcx.flag:= Header[1];
      pcx.version:= Header[2];
      pcx.encoded:= Header[3];
      pcx.xmin:= Header[5]+(Header[6] shl 8);
      pcx.ymin:= Header[7]+(Header[8] shl 8);
      pcx.xmax:= Header[9]+(Header[10] shl 8);
      pcx.ymax:= Header[11]+(Header[12] shl 8);
      XVS:= ((pcx.xmax-pcx.xmin) div 320)+1;
      YVS:= ((pcx.ymax-pcx.ymin) div 200)+1;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure LoadHugeHeader(var file_in: file; var XVS,YVS: word);
  { llegim directament els 128 bytes de la cap‡alera per a optimitzar }
    var
      Header: array [1..128] of byte;

    begin
      blockread(file_in,Header,PCXHeader);
      pcx.flag:= Header[1];
      pcx.version:= Header[2];
      pcx.encoded:= Header[3];
      pcx.xmin:= Header[5]+(Header[6] shl 8);
      pcx.ymin:= Header[7]+(Header[8] shl 8);
      pcx.xmax:= Header[9]+(Header[10] shl 8);
      pcx.ymax:= Header[11]+(Header[12] shl 8);
      XVS:= ((pcx.xmax-pcx.xmin) div 320)+1;
      YVS:= ((pcx.ymax-pcx.ymin) div 200)+1;
      MAXCameraX:= pcx.xmax - (320 shr 1) +1;
      MINCameraX:= pcx.xmin + (320 shr 1);
      MAXCameraY:= pcx.ymax - (200 shr 1) +1;
      MINCameraY:= pcx.ymin + (200 shr 1);
    end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure DrawPCX(var file_in: file; address: word);
    const
      max_dades=8192;

    var
      compte,y,x,offset,i,k,pos: word;
      ptr_dada: array [1..max_dades] of byte;
      dades_disponibles: longint;
      flag_compte: byte;

    procedure PaintPixel;
      begin
      	x:= pos mod ((pcx.xmax-pcx.xmin)+1);  {calcular la posicio}
        y:= pos div ((pcx.xmax-pcx.xmin)+1);  {del pixel}
        offset:= Coffset(x,y);
        {offset:= (y shl 8)+(y shl 6)+x;}
        mem[address:offset]:= ptr_dada[i];    {pintar en memoria}
        flag_compte:= 0;
        inc(pos)
      end;


    begin
      pos:= 0;
      flag_compte:= 0;
      dades_disponibles:= SizePCXData;
      repeat
      { si dades disponibles>=15000 bytes ... }
        if (dades_disponibles >= max_dades) then
          begin
          dades_disponibles:= dades_disponibles-max_dades;
          blockread(file_in,ptr_dada,max_dades);
          i:=1;
          { repetir fins completar el bloc }
          repeat
            { la dada es comptador? }
            if ((ptr_dada[i] and $C0) = $C0) then
              begin
              compte:= ptr_dada[i] and $3F;
              { segent dada }
              inc(i);
              if (i > max_dades) then
                begin
                i:= max_dades;
                blockread(file_in,ptr_dada[i],1);
                dec(dades_disponibles);
                end;
              { repetir el pixel compte vegades }
                if ( i <= max_dades) then for k:=1 to compte do PaintPixel;
              end
            else PaintPixel;
          { segent dada }
          inc(i);
          until (max_dades+1 = i);
          end
        { ... sino (dades disponibles<max_dades,ultim bloc de dades) }
        else
          begin
          i:= 1;
          { llegir un bloc de dades disponibles }
          blockread(file_in,ptr_dada,dades_disponibles);
          { repetir dades_disponibles }
          repeat
            { comptador? }
            if ((ptr_dada[i] and $C0) = $C0) then
              begin
              compte:= ptr_dada[i] and $3F;
              { segent dada }
              inc(i);
              dec(dades_disponibles);
              for k:= 1 to compte do
                begin
                x:= pos mod ((pcx.xmax-pcx.xmin)+1);  {calcular la posicio}
                y:= pos div ((pcx.xmax-pcx.xmin)+1);  {del pixel}
                offset:= COffset(x,y);
                mem[address:offset]:= ptr_dada[i];    {pintar en memoria}
                inc(pos);        {segent dada}
                end;
              inc(i);
              dec(dades_disponibles);
              compte:= 1;
              end
            else
              begin
              x:= pos mod ((pcx.xmax-pcx.xmin)+1);  {calcular la posicio}
              y:= pos div ((pcx.xmax-pcx.xmin)+1);  {del pixel}
              offset:= COffset(x,y);
              mem[address:offset]:= ptr_dada[i];    {pintar en memoria}
              inc(pos);
              {segent dada}
              inc(i);
              dec(dades_disponibles);
              end;
          until dades_disponibles<=0;
          end;
      until (dades_disponibles <= 0);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure LoadPalette(var file_in: file);
var
  pal: array [1..SizePalette] of byte;
  dada: byte;
  i: word;

  begin
    	{ 12 que indica la presŠncia de la paleta per• no pertany a ella }
    	blockread(file_in,dada,1);
      { comencem pel color 0 }
      port[$3c8]:= 0;
      {seek(file_in,filesize(file_in)-768);}
      { llegim totes les dades de la paleta }
      blockread(file_in,pal,SizePalette);

      i:= 0;
      while (i < SizePalette) do
      {pasem les dades al port de la VGA}
         begin
            port[$3C9]:= pal[i+1] shr 2;
            port[$3C9]:= pal[i+2] shr 2;
            port[$3C9]:= pal[i+3] shr 2;
            i:= i+3;
         end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure ColocaEnPoll(XVS,YVS: byte);
  	var
    	aux: PtrVScreen;
      waux: word;
      i: byte;

    begin
      for i:= 1 to (XVS * YVS) do
				begin
        	InitVirtual(aux,waux);
          Cls(0,waux);
					streetpoll[i]:= waux;
        end;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
	procedure LoadHugePCX(filename: string);
		var
			file_in: file;
      pos: byte;

    begin
    	assign(file_in,filename);
      reset(file_in,1);
      SizePCX:= filesize(file_in);
      SizePCXData:= SizePCX-SizePalette-1-PCXHeader;
      LoadHugeHeader(file_in,XVS,YVS);
      ColocaEnPoll(XVS,YVS);
      LoadPalette(file_in);
      close(file_in);
      {TopList(BackGround);
      for pos:= 1 to 4 do
		  	begin
    			NextFromList(BackGround);
		      streetpoll[pos]:= RestoreWordFromList(BackGround);
    		end;               }
      Cls(0,WP);
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
	procedure LoadPCX(filename: string; address: word);
		var
			file_in: file;

    begin
    	assign(file_in,filename);
      reset(file_in,1);
      SizePCX:= filesize(file_in);
      SizePCXData:= SizePCX-SizePalette-1-PCXHeader;
      LoadHeader(file_in,AUXXVS,AUXYVS);
      DrawPCX(file_in,address);
      LoadPalette(file_in);
      close(file_in);
      Cls(0,WP);
    end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure LoadPCXP(filename: string; offset: word; address: word);
  var
    file_in: file;

begin
  assign(file_in,filename);
  reset(file_in,1);
  seek(file_in,offset);
  SizePCX:= filesize(file_in);
  SizePCXData:= SizePCX-SizePalette-1-PCXHeader;
  LoadHeader(file_in,AUXXVS,AUXYVS);
  DrawPCX(file_in,address);
  LoadPalette(file_in);
  close(file_in);
  Cls(0,WP);
end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A SCROLLS												 	}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure scroll(orig,dest,desp:word); assembler;
	asm
  	push ds;
    {inicialitzar l'acces a les memories orige i desti}
    mov ax,orig;
    mov ds,ax;
    xor si,si;

    mov ax,dest;
    mov es,ax;
    mov di,desp;

    mov cx,64000;            {bytes en una pantalla}
    sub cx,desp;     				{bytes a copiar}
    shr cx,1;                {words a copiar}
    {comen‡ar a copiar primer tros}
    rep movsw;

    mov cx,desp;
    shr cx,1;
    xor di,di;
    {comen‡ar a copiar segon tros}
    rep movsw;

  	pop ds;
  end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*procedure VerticalScroll(zona1,zona2: word; i: integer);
	begin
		inc(VScrollCount,i);
		VScrollCount:= VScrollCount mod 200;
    {WaitRetrace;}
		scroll(zona1,zona2,VScrollCount*320);
	end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
procedure HorizontalScroll(zona1,zona2: word; i: integer);
	begin
   	inc(HScrollCount,i);
    {HScrollCount:= HScrollCount mod 320;}
    {WaitRetrace;}
    scroll(zona1,zona2,HScrollCount);
  end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
	{ Copia un tro‡ de pantalla virtual en una altra }
  procedure CopyChunk(pantalla,xini,xfi,mem_dest,posx:word); assembler;
	  asm
			push ds

		  mov ax,mem_dest
  		mov es,ax

	   	mov ax,pantalla
 		 	mov ds,ax

	   	mov cx,200

 	 		mov dx,xfi
	 		sub dx,xini

			@bucle1:
 				mov bx,cx{push cx}

	   		mov si,xini

  	 		shl cx,8
 	 			mov di,cx
 				shr cx,2
	 			add di,cx

  	 		mov cx,dx
 	 			{shr cx,1}

	 			add si,di

 				add di,posx

   			rep movsb{w}

 	 			mov cx,bx{pop cx}
	 		loop @bucle1

  	 	mov si,xini
 			mov di,posx
	 		mov cx,dx
  	 	shr cx,1
 	 		rep movsw

	   	pop ds
 		end;

  function CalcularPantallesQueOcupa(x,y: integer): byte;
		var
  		h,v: byte;

	  begin
  		if ((x mod 320) = 160)
    		then h:= 1
      	else h:= 2;
	    if ((y mod 200) = 100)
  	  	then v:= 1
    	  else v:= 2;
	    CalcularPantallesQueOcupa:= h*v;
  	end;

	procedure CopiarUnaPantalla(x,y: integer);
		var
  		v,i: byte;
	    w: word;

		begin
	  	v:= QuinaPantalla(XVS,x,y);
  	  w:= streetpoll[v];
    	Flip(w,WP);
	  end;

	procedure CopiarDuesPantalles(x,y: integer);
		var
  		xxx,yyy: array [1..2] of integer;	{ coord's sup. esq. i inf. dr. de la c…mera     }
    	v,i: byte;
	    w: array [1..2] of word;

		begin
	  	xxx[1]:= x-(320 shr 1){ mod 320};
  	  xxx[2]:= (x+(320 shr 1)-1){ mod 320};
    	yyy[1]:= y-(200 shr 1){ mod 200};
	    yyy[2]:= (y+(200 shr 1)-1){ mod 200};

  	  for i:= 1 to 2 do
				begin
  	    	v:= QuinaPantalla(XVS,xxx[i],yyy[i]);
					w[i]:= streetpoll[v];
      	end;
                                          {319}
	    CopyChunk(w[2],0,(xxx[2] mod 320),WP,320-(xxx[1] mod 320));
  	  CopyChunk(w[1],(xxx[1] mod 320),320,WP,0);
                                     {319}
	  end;

	procedure Camera(x,y: integer);
		var
  		pant: byte;						{ pantalles que abarca la c…mera                }

	  begin
    	if (x > MAXCameraX)
      	then	x:= MAXCameraX
        else
        	if (x < MINCameraX)
          	then x:= MINCameraX;

      if (y > MAXCameraY)
      	then	y:= MAXCameraY
        else
        	if (y < MINCameraY)
          	then y:= MINCameraY;

  	  pant:= CalcularPantallesQueOcupa(x,y);

	    case pant of
  	  	1: CopiarUnaPantalla(x,y);
    	  2: CopiarDuesPantalles(x,y);
      	{4:}
	    end;
    end;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       PROCEDIMENTS PER A LES LLISTES  									 	}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*	procedure CreateList(var ll: List);
    var
      aux: ptr;

    begin
      new(aux);
      aux^.s:= nil;
      ll.p:= aux;
      ll.u:= aux;
      ll.a:= aux;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
  procedure InsertInList(var ll: List; e: Element; w: word);
    var
      aux: ptr;

    begin
      new(aux);
      aux^.d:= e;
      aux^.w:= w;
      aux^.s:= ll.a^.s;
      ll.a^.s:= aux;
      if ll.a= ll.u then ll.u:= aux;
      ll.a:= aux;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  procedure DeleteFromList(var ll: List);
    var
      aux: ptr;

    begin
      new(aux);
      if ll.a^.s= ll.u then ll.u:= ll.a;
      aux:= ll.a^.s;
      ll.a^.s:= aux^.s;
      dispose(aux);
    end; *)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  function RestoreWordFromList(ll: List): word;
    begin
      RestoreWordFromList:= (ll.a^.w);
    end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  function RestoreVScreenFromList(ll: List): element;
    begin
      RestoreVScreenFromList:= (ll.a^.d);
    end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  procedure TopList(var ll: List);
    begin
      ll.a:= ll.p;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  procedure BottomList(var ll: List);
    begin
      ll.a:= ll.u;
    end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  procedure NextFromList(var ll: List);
    begin
      ll.a:= ll.a^.s;
    end;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  function IsEmpty(ll: List): boolean;
    begin
      IsEmpty:= (ll.p= ll.u);
    end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*  function EndOfList(ll: List): boolean;
    begin
      EndOfList:= (ll.a= ll.u);
    end;*)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
begin
	SavePalette(BIOSPal);
  XVS:= 0;
  YVS:= 0;
end.
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
(*     ACONSEGUIR UN PROCEDIMENT PER A LLEGIR PALETES EN FORMAT *.PAL      *)
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{ En una llista el primer node est… buit, la informaci¢ comen‡a en el segon }
{ per tant, si fem:                                                         }
{                                                                           }
{ (1) TopList(llista);                                                      }
{ (2) w:= RestoreWordFromList(llista);                                      }
{ (3) Flip(w,VGA);                                                          }
{                                                                           }
{ no eixir… res, haurem d'inserir entre les instruccions (1) i (2):         }
{                                                                           }
{ NextFromList(llista);                                                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}