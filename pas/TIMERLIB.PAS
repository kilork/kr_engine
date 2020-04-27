unit TimerLIB;

interface

function GetTick : LongInt;

implementation

uses Dos;

var Time : LongInt;
    reg  : registers;

function GetTick : LongInt;

begin
{  asm
    mov ah, 00h
    int 1Ah
  end; }
  reg.ah := 0;
  intr( $1A, reg );
  {Time := reg.cx;}
  Time := {Time shl 16} + reg.dx;
  GetTick := Time;
end;

end.