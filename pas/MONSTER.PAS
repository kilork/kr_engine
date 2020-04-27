program ja_tupoj;

uses Crt, Graph, TimerLIB, Anim_LIB;

var
  gd,
  gm      : Integer;
  i       : Integer;
  OldTime,
  NewTime : LongInt;
  Ch      : Char;
  k       : Integer;

begin
  gd := InstallUserDriver( 'SVGA256', nil );
  gm := 1;
  InitGraph( gd, gm, 'c:\pascal\bgi' );
  SetColor( 15 );
  Rectangle( 0, 0, 639, 399 );
  for i := 1 to 255 do
    begin
      SetColor( i );
      Rectangle( Random( 638 )+1, Random( 398 )+1,
                 Random( 638 )+1, Random( 398 )+1 );
    end;
  SetActivePage( 1 );
  SetColor( 15 );
  Rectangle( 0, 0, 639, 399 );
  for i := 1 to 255 do
    begin
      SetColor( i );
      Rectangle( Random( 638 )+1, Random( 398 )+1,
                 Random( 638 )+1, Random( 398 )+1 );
    end;
  SetActivePage( 0 );
  repeat
    SetVisualPage( 0 );
    Delay( 10000 );
    SetVisualPage( 1 );
    Delay( 10000 );
  until KeyPressed;
  ReadLn;
  OldTime := GetTick;
  i := 1;
  SetVisualPage( 0 );
  k := 0;
  repeat
    SetVisualPage( k );
    NewTime := GetTick;
    if NewTime - OldTime > 0 then
      begin
        Bar( i, 1, i+1, 398 );
        if NewTime mod 18 = 0 then
          begin
            Sound( 500 );
            Delay( 30 );
            NoSound;
          end;
        inc( i, NewTime-OldTime );
        if i > 637 then
          begin
            i := 000;
            k := k xor 1;
            SetActivePage( k );
          end;
        OldTime := NewTime;
      end;
    SetVisualPage( k xor 1 );
    if KeyPressed then
      Ch := ReadKey;
  until Ch = #13;
  CloseGraph;
end.