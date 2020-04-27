program Main_Engine;

uses Crt, Graph, Anim_LIB, TimerLIB, Obj_LIB;

var
  gd,
  gm      : Integer;
  i       : Integer;
  OldTime,
  NewTime : LongInt;
  Ch      : Char;
  k       : Integer;

procedure InitDefaults;

begin
  Create_Plane( 0,100,639,399, White, Green, 32764 );
  Create_Plane( 0,0,639,99, Blue, Blue, 32767 );
  Create_Circle( -20,40,20,20, Blue, Yellow, 32766 );
  Scene[ NScene ].x := 50;
  for k := 1 to 10 do
    begin
      i := Random( 50 );
      Create_Cloud( -(i shl 3), 30, i, i,
                     LightGray, Random( 256 ), 32766 - Random( 5 ) );
      Scene[ NScene ].x := Random( 640 );
    end;
  Create_TPT( 2, 335, 0, 0, 0, 0, 0 );
  for i := 1 to 8 do
    Create_Ovca( 10+Random(240), 100 + i shl 4, 32700+30-i );
  Create_Oblakov( 50, 270, 32500 );
  Create_House( 300, 200, 32700 );
  Create_Light( 350, 253, 32600 );
  Create_Sosulka( 300, 200, 0, 0 , Blue, Blue, 32600 );
  ZBuffer;
  if NScene = MAX_OBJECTS then
    begin
      Sound( 2300 );
      Delay( 5000 );
      NoSound;
    end;
  RenderScene;
  Flip;
end;

begin
  Randomize;
  gd := InstallUserDriver( 'SVGA256', nil );
  gm := 1;
  InitGraph( gd, gm, 'c:\pascal\bgi' );
  InitDefaults;
  Ch := #0;
  repeat
    OnTimerTick;
    if NeedToRedraw then
      begin
        RenderScene;
        Flip;
        NeedToRedraw := false;
      end;
    if KeyPressed then
      Ch := ReadKey;
  until Ch = #13;
  CloseGraph;
  WriteLn( NScene );
end.