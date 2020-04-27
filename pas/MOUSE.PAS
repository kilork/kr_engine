unit Mouse;

interface

type
  MouseItemType = record
    X1, Y1, X2, Y2 : integer;
    Butt : word;
    Key : word;
  end;

  MouseHandlerType = Procedure ( Mask, Buttons, X, Y, DX, DY : integer );

const
  LeftButton = 1;
  RightButton = 2;
  CenterButton = 4;
  AnyButton = 7;
  TextRatioX : Byte = 8;
  TextRatioY : Byte = 8;

function IsMouse : Boolean;

function InitMouse : Boolean;

procedure SetMousePage ( page : Byte );

function GetMousePage : Byte;

procedure SetStepToPixel( Hor, Ver : integer );

procedure GetStepToPixel ( var Hor, Ver : integer);

procedure SetDoubleSpeed ( Speed : Word );

function GetDoubleSpeed : word;

function MouseTextCooX ( x : integer ) : Byte;

function MouseTextCooY ( y : integer ) : Byte;

function MouseGraphCooX ( x : byte ) : integer;

function MouseGraphCooY ( y : byte ) : integer;

procedure MouseWhereXY ( var x, y : integer );

procedure MouseGotoXY ( x , y : Integer );

function MouseWhereX : integer;

function MouseWhereY : integer;

function MouseIn( X1, Y1, X2, Y2 : Integer ) : boolean;

function NumButton : Byte;

procedure GetMouseState ( var Butt,X,Y : integer );

function MousePressed : Boolean;

procedure MouseButtPressed ( Butt : Integer; var Stat, Count, X, Y : integer );

procedure MouseButtReleased ( Butt : Integer; var Stat, Count, X, Y : integer );

procedure MouseWindow ( x1, y1, x2, y2 : integer );

procedure MouseScreen;

procedure ShowMouse;

procedure HideMouse;

procedure MouseTextCursor( ScrMask, CurMask : word );

procedure MouseBlink ( YUp, YDn : Byte );

procedure MouseGraphCursor ( var ScrCurMask; x, y : Byte );

function MouseBuffSize : word;

procedure SaveMouse ( var Buff );

procedure RestoreMouse ( var Buff );

procedure SetMouseItem ( NItem : byte; var Items );

procedure AddMouseItem ( Item : MouseItemType );

procedure ClearMouseItems;

procedure GetMouseItem ( var NItem : Byte; var Items );

function KeyOrMousePressed : Boolean;

function ReadKeyOrMouse : Char;
{
procedure SetMouseHandler ( Mask : word; Proc : MouseHandlerType );

procedure ChangeMouseHandler ( Mask : word; Proc : MouseHandlerType;
                               var OldMask : word; var OldProc : Pointer );

procedure ClearMouseHandler;
}

{ ************* } IMPLEMENTATION { ************* }

uses Dos, Crt;

type
  MouseItems = array [ 1..2*MaxInt div SizeOf( MouseItemType) ] of MouseItemType;
  PMouseIt = ^MouseItems;
const
  MousePresent : Boolean = False;
  ItemsList    : PMouseIt = NIL;
  NMouseItem : Byte = 0;
  MouseVisible : Boolean = False;
  x1m : Integer = 0;
  y1m : Integer = 0;
  x2m : Integer = 639;
  y2m : Integer = 199;
  Speed2 : word = 128;
  VerRat : integer = 8;
  HorRat : Integer = 8;
  NButton : Byte = 0;
var
  Reg : registers;

function IsMouse : Boolean;

var
  p : Pointer;
  k,x,y : integer;
  Is : Boolean;
begin
  if NButton = 0 then
    begin
      GetIntVec( $33, p );
      Is := p <> NIL;
      if Is then with Reg do
        begin
          ax := $3;
          bx := $FFFF;
          Intr( $33, Reg );
          Is := bx <> $FFFF
        end;
      MousePresent := Is
    end;
  IsMouse := MousePresent
end;

function InitMouse : boolean;

begin
  with Reg do
    begin
      ax := 0;
      Intr ( $33, Reg );
      MousePresent := ax=$FFFF;
      NButton := bx
    end;
  ClearMouseItems;
  SetMousePage(0);
  HideMouse;
  MouseScreen;
end;

procedure SetMousePage( Page : byte );

begin
  with Reg do
    begin
      ax := $1D;
      bl := Page;
      bh := 0;
      Intr( $33, Reg )
    end
end;

function GetMousePage : Byte;

begin
  with Reg do
    begin
      ax := $1E;
      Intr ($33, Reg );
      GetMousePage := bl
    end
end;

procedure SetStepToPixel ( Hor, Ver : Integer );

begin
  if IsMouse then With Reg do
    begin
      ax := $0F;
      cx := Hor and $7FFF;
      dx := Ver and $7FFF;
      HorRat := cx;
      VerRat := dx;
      Intr ( $33, Reg )
    end
end;

procedure GetStepToPixel ( var Hor, Ver : Integer );

begin
  if IsMouse then with Reg do
    begin
      Hor := HorRat;
      Ver := VerRat
    end
end;

procedure SetDoubleSpeed( Speed : word );

begin
  if IsMouse then with Reg do
    begin
      ax := $13;
      dx := Speed;
      Speed2 := Speed;
      Intr($33,Reg)
    end
end;

function GetDoubleSpeed : word;

begin
  GetDoubleSpeed := Speed2
end;

function MouseTextCooX ( x : Integer ) : Byte;

begin
  MouseTextCooX := x div TextRatioX+1
end;

function MouseTextCooY ( y : Integer ) : Byte;

begin
  MouseTextCooY := Y div TextRatioY+1
end;

function MouseGraphCooX ( x  : byte ) : integer;

begin
  MouseGraphCooX := ( x-1 ) * TextRatioX
end;

function MouseGraphCooY ( y  : byte ) : integer;

begin
  MouseGraphCooY := ( y-1 ) * TextRatioY
end;

procedure MouseWhereXY ( var x, y : integer );

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr ($33, Reg );
      X := cx;
      Y := dx
    end
  else
    begin
      x := -1;
      y := -1
    end
end;

procedure MouseGotoXY ( X, Y : integer );

begin
  if IsMouse then with Reg do
    begin
      ax := $4;
      cx := X;
      dx := Y;
      intr( $33, Reg )
    end
end;

function MouseWhereX : integer;

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr($33, Reg);
      MouseWhereX := cx;
    end
  else
    MouseWhereX := 0
end;

function MouseWhereY : integer;

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr($33, Reg);
      MouseWhereY := dx;
    end
  else
    MouseWhereY := 0
end;

function MouseIn(x1,y1,x2,y2 : integer ) : boolean;

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr($33, Reg );
      MouseIn := ( cx >= x1) and ( cx <= x2 ) and ( dx >= y1 ) and ( dx <= y2 )
    end
end;

function NumButton : byte;

begin
  NumButton := NButton
end;

procedure GetMouseState ( var Butt, X, Y : integer );

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr($33, Reg );
      Butt := bx;
      X := cx;
      Y := dx
    end
  else
    begin
      Butt := 0;
      X := 0;
      Y := 0
    end
end;

function MousePressed : boolean;

begin
  if IsMouse then with Reg do
    begin
      ax := $3;
      Intr($33, Reg );
      MousePressed := bx <> 0
    end
  else
    MousePressed := False
end;

procedure MouseButtPressed ( Butt : integer; var Stat, Count, X, Y : integer );

begin
  if IsMouse then with Reg do
    begin
      ax := $5;
      bx := Butt;
      Intr($33, Reg );
      Count := bx;
      X := cx;
      Y := dx;
      Stat := bx
    end
  else
end;

procedure MouseButtReleased( Butt : Integer; var Stat, Count, X, Y : Integer );

begin
  if IsMouse then with Reg do
    begin
      ax := $6;
      bx := Butt;
      Intr($33, Reg );
      Count := bx;
      X := cx;
      Y := dx;
      Stat := bx
    end
  else
end;

procedure MouseWindow(x1,y1,x2,y2 : integer );

begin
  if IsMouse then
    begin
      x1m := x1;
      y1m := y1;
      x2m := x2;
      y2m := y2;
      with Reg do
        begin
          ax := $7;
          cx := x1;
          dx := x2;
          Intr($33, Reg);
          ax := $8;
          cx := y1;
          dx := y2;
          Intr($33, Reg)
        end
    end
end;

procedure MouseScreen;

var x2, y2 : integer;

begin
  if IsMouse then with Reg do
    begin
      ah := $F;
      Intr($10, Reg);
      case al of
        1,4,5,13 : begin
                     x2 := 319;
                     y2 := 199
                   end;
        15, 16 : begin
                   x2 := 639;
                   y2 := 349
                 end;
        17, 18 : begin
                   x2 := 639;
                   y2 := 479
                 end;
        else
          x2 := 639;
          y2 := 199
        end
    end;
  MouseWindow(0,0,x2,y2)
end;

procedure ShowMouse;

begin
  if IsMouse and not MouseVisible then with Reg do
    begin
      ax := $1;
      Intr($33, Reg);
      MouseVisible := True
    end
end;

procedure HideMouse;

begin
  if IsMouse and MouseVisible then with Reg do
    begin
      ax := $2;
      Intr($33, Reg);
      MouseVisible := False
    end
end;

procedure MouseTextCursor( ScrMAsk, CurMask : word );

begin
  if IsMouse then with Reg do
    begin
      ax := $A;
      bx := 0;
      cx := ScrMask;
      dx := CurMask;
      Intr($33, Reg)
    end
end;

procedure MouseBlink( YUp, YDn : byte );

begin
  if IsMouse then with Reg do
    begin
      ax := $A;
      bx := 1;
      cx := YUp;
      dx := YDn;
      Intr($33, Reg);
    end
end;

procedure MouseGraphCursor ( var ScrCurMask; X, Y : Byte );

begin
  if IsMouse then with Reg do
    begin
      ax := $9;
      bx := X;
      cx := Y;
      es := seg ( ScrCurMask );
      dx := ofs ( ScrCurMask );
      Intr($33, Reg);
    end
end;

function MouseBuffSize : word;

begin
  if IsMouse then with Reg do
    begin
      ax := $15;
      bx := 0;
      Intr($33, Reg);
      MouseBuffSize := bx
    end
  else MouseBuffSize := 0
end;

procedure SaveMouse ( var Buff );

begin
  if IsMouse then with Reg do
    begin
      ax := $16;
      es := seg ( Buff );
      dx := ofs ( Buff );
      Intr($33, Reg);
    end
end;

procedure RestoreMouse ( var Buff );

begin
  if IsMouse then with Reg do
    begin
      ax := $17;
      es := seg ( Buff );
      dx := ofs ( Buff );
      Intr($33, Reg);
    end
end;

const
  DoubleChars: boolean = false;
var SecChar : Char;

procedure SetMouseItem(NItem : byte; var Items );

begin
  if IsMouse then with Reg do
    begin
      ClearMouseItems;
      GetMem(ItemsList, NItem*SizeOf(MouseItemType));
      Move(Items,ItemsList^, NItem*SizeOf(MouseItemType));
      NMouseItem := NItem
    end
end;

procedure AddMouseItem ( Item : MouseItemType );

var
  p : PMouseIt;
  k : Byte;

begin
  if IsMouse then
    begin
      k := NMouseItem;
      GetMem(p, (k+1)*SizeOf(MouseItemType));
      Move(ItemsList^, P^, k* SizeOf(MouseItemType));
      Move(Item, P^[k+1], k* SizeOf(MouseItemType));
      ClearMouseItems;
      NMouseItem := k+1;
      ItemsList := P
    end
end;

procedure ClearMouseItems;

begin
  if IsMouse and ( NMouseItem <> 0 ) then
    begin
      FreeMem( ItemsList, NMouseItem*SizeOf(MouseItemType));
      NMouseItem := 0
    end
end;

procedure GetMouseItem ( var NItem : Byte; var Items );

begin
  if IsMouse and ( NMouseItem <> 0 ) then
    begin
      NItem := NMouseItem;
      Move(ItemsList^, Items, NMouseItem*SizeOf(MouseItemType))
    end
end;

function KeyOrMousePressed : boolean;

var b, k : integer;
    MouseActive : boolean;

begin
  if KeyPressed then
    KeyOrMousePressed := true
  else with Reg do
    begin
      ax := $3;
      intr($33, Reg);
      if (bx<>0) and  (NMouseItem <>0 ) then
        begin
          MouseActive := False;
          for k := 1 to NMouseItem do
          if not MouseActive then
            with ItemsList^[k] do
          begin
            case Butt of
              LeftButton : b := bx and LeftButton;
              RightButton : b := bx and RightButton;
              CenterButton : b := bx and CenterButton;
              AnyButton : b := bx
            else
              b := 0;
            end;
            MouseActive := (b <> 0 ) and
              MouseIn( MouseGraphCooX(x1), MouseGraphCooY(y1),
                       MouseGraphCooX(x2), MouseGraphCooY(y2));
          end;
        KeyOrMousePressed := MouseActive
      end
    else
      KeyOrMousePressed := False
    end
end;

function ReadKeyOrMouse : char;

var
  k : Byte;
  b, bb : word;
  MouseActive : boolean;
label
  loop;
begin
loop:
  if not IsMouse or KeyPressed then
    ReadKeyOrMouse := ReadKey
  else if DoubleChars then
    begin
      DoubleChars := False;
      ReadKeyOrMouse := SecChar
    end
  else if NMouseItem <> 0 then with Reg do
    begin
      MouseActive := False;
      ax := $3;
      Intr($33, Reg);
      bb := bx;
      if bb <> 0 then
        for k := 1 to NMouseItem do
          if not MouseActive then
            with ItemsList^[k] do begin
              case Butt of
                LeftButton : b := bb and LeftButton;
                RightButton : b := bb and RightButton;
                CenterButton : b := bb and CenterButton;
                AnyButton : b := bb;
              else
                b := 0;
              end;
              if (b <> 0) and MouseIn( MouseGraphCooX(x1), MouseGraphCooY(y1),
                                       MouseGraphCooX(x2), MouseGraphCooY(y2)) then
                begin
                  MouseActive := true;
                  ReadKeyOrMouse := Char( Lo ( Key ));
                  if Lo( Key ) = 0 then
                    begin
                      DoubleChars := True;
                      SecChar := chr( Hi(Key))
                    end
                end
            end;
          if not MouseActive then
            goto loop
        end
      else
        ReadKeyOrMouse := ReadKey
end;

end.
