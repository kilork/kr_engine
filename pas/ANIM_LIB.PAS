unit Anim_LIB;

{ модуль содержит типы и процедуры для работы с анимацией }

{*----------------*}
{*}  interface   {*}
{*----------------*}

const
  MAX_OBJECTS = 100;

type
  Sprite = record
             x, y, z, dx, dy : Integer;
             phase : Integer;
             old_time : LongInt;
             ph_time : array[ 0..255 ] of word;
             SetPhase : procedure( sprite, phase : Integer );
             DrawMe : procedure( sprite, x, y, dx, dy : Integer );
             InMe : function( x, y : Integer ) : boolean;
             Extend : array [ 0..30 ] of word;
           end;
var
  Scene : array [ 1..MAX_OBJECTS ] of Sprite;
  ZScene : array [ 1..MAX_OBJECTS ] of record
                                 i : Integer;
                                 z : Integer;
                               end;
  NScene : Integer;

  NeedToRedraw : Boolean;
  NeedToReZBuffer : Boolean;

procedure ZBuffer;
{ Z-буффер }

{ процедура прорисовки сцены }
procedure RenderScene;

{ осуществляет анимацию }
procedure OnTimerTick;

{ переключение между поверхностями }
procedure Flip;

{ проверка на пересечение прямоугольников }
function RectIntersect( x, y, dx, dy,
                        x0, y0, x1, y1 : Integer ) : boolean;

{*--------------------*}
{*}  implementation  {*}
{*--------------------*}

uses TimerLIB, { подключаем библиотеку таймера }
     Graph,
     Obj_LIB,  { подключаем библиотеку объектов }
     Crt;

{ процедура инициализации Z-буффера }
procedure InitZScene;

var i : Integer;

begin
  for i :=  1 to NScene do
    begin
      ZScene[ i ].z := Scene[ i ].z;
      ZScene[ i ].i := i;
    end;
end;

{ непосредственно Z-буффер }
procedure ZBuffer;

var i, j : Integer;
    temp, k : Integer;

begin
  InitZScene;
  if NScene > 1 then
    for i := 1 to NScene-1 do
      begin
        k := ZScene[ i ].z;
        for j := i to NScene do
          if ZScene[ j ].z > k then
            begin
              temp := ZScene[ i ].i;
              ZScene[ i ].i := ZScene[ j ].i;
              ZScene[ i ].z := ZScene[ j ].z;
              ZScene[ j ].i := temp;
              ZScene[ j ].z := k;
              k := ZScene[ i ].z;
            end;
      end;
end;

{ как ясно из названия, процедура занимается рисованием сцены }
procedure RenderScene;

var i : Integer;

begin
{  SetFillStyle( 1, 0 );
  Bar( 0, 0, 639, 399 );
  Bar( 0, 0, 639, 399 ); }
  for i :=  1 to NScene do
    with Scene[ ZScene[ i ].i ] do
      DrawMe( ZScene[ i ].i, x, y, dx, dy );
end;

{ собственно вот это осуществляет анимацию }
procedure OnTimerTick;

var new_time : LongInt;
    i        : Integer;
    t        : Integer;

begin
  for i := 1 to NScene do
    begin
      new_time := GetTick;
      t := Scene[ i ].phase;
      if Scene[ i ].ph_time[ t ] <
         new_time - Scene[ i ].old_time then
        begin
          Inc( t );
          if ( Scene[ i ].ph_time[ t ] = 0 ) or ( t = 256 ) then
            t := 0;
          Scene[ i ].SetPhase( i, t );
          Scene[ i ].phase := t;
          Scene[ i ].old_time := GetTick;
          NeedToRedraw := true;
        end;
    end;
end;

const NowIsVisible : Integer = 0;

{ переключение между поверхностями }
procedure Flip;

begin
  SetActivePage( NowIsVisible );
  NowIsVisible := NowIsVisible xor 1;
  SetVisualPage( NowIsVisible );
{  Sound( 600 ); }
{   Delay( 1000 ) }
{   NoSound; }
end;

{ проверка на пересечение прямоугольников }
function RectIntersect( x, y, dx, dy,
                        x0, y0, x1, y1 : Integer ) : boolean;

begin
  x0 := x0 - dx;
  x0 := x0 + dx;
  y0 := y0 - dy;
  y0 := y0 + dy;
  if ( x - x0 ) * ( x - x1 ) <= 0 then
    begin
      if ( y - y0 ) * ( y - y1 ) <= 0 then
        RectIntersect := true
    end
  else
    RectIntersect := false
end;

begin
  NScene := 0;
end.