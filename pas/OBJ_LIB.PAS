unit Obj_LIB;

{ инициализация и обработка объектов сцены }

{*----------------*}
{*}  interface   {*}
{*----------------*}

uses Anim_LIB, Crt, File_LIB;

var i : Integer;
    TPT : array [ 0..100 ] of TPT_64x64;

const N_TPT : word = 0;
      Sun : integer = -1;
      Sun_x0 : integer = 0;
      Sun_y0 : integer = 0;
      NumOfCoveredClouds : integer = 0;
      LightOn : boolean = false;

{ ******/ ОБЪЕКТ - КАРТИНКА /****** }

procedure Create_TPT( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_TPT( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_TPT( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА ПЛОСКОСТЬ /****** }

procedure Create_Plane( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Plane( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Plane( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА КРУГ /****** }

procedure Create_Circle( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Circle( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Circle( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА ДЫМ /****** }

procedure Create_Fog( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Fog( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Fog( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА ОБЛАКО /****** }

procedure Create_Cloud( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Cloud( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Cloud( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА СОСУЛЬКА /****** }

procedure Create_Sosulka( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Sosulka( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Sosulka( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА ОЗЕРО /****** }

procedure Create_Ozero( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Ozero( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Ozero( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА КАПЛЯ /****** }

procedure Create_Kaplja( x0, y0, dx0, dy0, color, color2, z0 : Integer );

procedure DrawMe_Kaplja( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Kaplja( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА КРЫША /****** }

procedure Create_Top( x0, y0, dx0, dy0, color, color2, z0,
                      x1, y1,
                      x2, y2 : Integer );

procedure DrawMe_Top( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Top( sprite, phase0 : Integer );


{ ******/ ОБЪЕКТЫ ТИПА ДОМИК /****** }

procedure Create_House( x0, y0, z0 : Integer );

procedure DrawMe_House( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_House( sprite, phase0 : Integer );

{ ******/ ОБЪЕКТЫ ТИПА ОВЦА /****** }

procedure Create_Ovca( x0, y0, z0 : Integer );

procedure DrawMe_Ovca( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Ovca( sprite, phase0 : Integer );

{ ******/ ОБЪЕКТЫ ТИПА ОБЛАКОВ /****** }

procedure Create_Oblakov( x0, y0, z0 : Integer );

procedure DrawMe_Oblakov( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Oblakov( sprite, phase0 : Integer );

{ ******/ ОБЪЕКТЫ ТИПА СВЕТ /****** }

procedure Create_Light( x0, y0, z0 : Integer );

procedure DrawMe_Light( sprite, x0, y0, dx0, dy0 : Integer );

procedure SetPhase_Light( sprite, phase0 : Integer );


{*--------------------*}
{*}  implementation  {*}
{*--------------------*}

uses Graph, TimerLIB;

{ ******/ ОБЪЕКТЫ ТИПА ОБЛАКОВ /****** }

procedure Create_Oblakov( x0, y0, z0 : Integer );

var i, j : integer;

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          ph_time[ 0 ] := Random( 5 );
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Oblakov;
          SetPhase := SetPhase_Oblakov;
          Inc( N_TPT, 2 );
          if N_TPT < 101 then
            begin
              TPT[ N_TPT-1 ] := LoadTPT_64( 'oblakov.tpt' );
              New( TPT[ N_TPT ] );
              for i := 0 to 63 do
                for j := 0 to 63 do
                  TPT[ N_TPT ]^[ i, j ] := TPT[ N_TPT-1 ]^[ i, 63 - j ];
              if TPT[ N_TPT ] = nil then
                begin
                  Dec( N_TPT,2 );
                  Dec( NScene );
                end
              else
                begin
                  Extend[ 3 ] := N_TPT;
                  Extend[ 2 ] := N_TPT-1;
                  Extend[ 1 ] := Random( 2 );
                end;
            end
          else
            begin
              Dec( N_TPT );
              Dec( NScene );
            end;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Oblakov( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
{      if Extend[ 1 ] = 1 then}
        DrawTPT_64( x, y, 0, TPT[ Extend[ 2 ] ] )
{      else
        DrawTPT_64( x, y, 0, TPT[ Extend[ 3 ] ] );}
    end;
end;

procedure SetPhase_Oblakov( sprite, phase0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      if Extend[ 1 ] = 1 then
        begin
          Dec( x, 1 );
          if x < 50 then
            Extend[ 1 ] := 2
        end
      else
        begin
          Inc( x, 1 );
          if x > 200 then
            Extend[ 1 ] := 1
        end
    end
end;

{ ******/ ОБЪЕКТ - КАРТИНКА /****** }

procedure Create_TPT( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          ph_time[ 0 ] := 18000;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_TPT;
          SetPhase := SetPhase_TPT;
          Inc( N_TPT );
          if N_TPT < 101 then
            begin
              TPT[ N_TPT ] := LoadTPT_64( 'logo2.tpt' );
              if TPT[ N_TPT ] = nil then
                begin
                  Dec( N_TPT );
                  Dec( NScene );
                end
              else
                Extend[ 3 ] := N_TPT;
            end
          else
            begin
              Dec( N_TPT );
              Dec( NScene );
            end;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_TPT( sprite, x0, y0, dx0, dy0 : Integer );

begin
  DrawTPT_64( x0, y0, 0, TPT[ Scene[ sprite ].Extend[ 3 ] ] )
end;

procedure SetPhase_TPT( sprite, phase0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      Inc( x );
      if x > 640 then
        x := -64;
    end;
end;

{ ******/ ОБЪЕКТЫ ТИПА СВЕТ /****** }

procedure Create_Light( x0, y0, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          ph_time[ 0 ] := 18000;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Light;
          SetPhase := SetPhase_Light;
          Inc( N_TPT );
          if N_TPT < 101 then
            begin
              TPT[ N_TPT ] := LoadTPT_64( 'light2.tpt' );
              if TPT[ N_TPT ] = nil then
                begin
                  Dec( N_TPT );
                  Dec( NScene );
                end
              else
                Extend[ 3 ] := N_TPT;
            end
          else
            begin
              Dec( N_TPT );
              Dec( NScene );
            end;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Light( sprite, x0, y0, dx0, dy0 : Integer );

begin
  if LightOn then
    DrawTPT_64( x0, y0, 0, TPT[ Scene[ sprite ].Extend[ 3 ] ] )
end;

procedure SetPhase_Light( sprite, phase0 : Integer );

begin
end;

{ ******/ ОБЪЕКТЫ ТИПА ОВЦА /****** }

const Ovca_id:integer = -1;

procedure Create_Ovca( x0, y0, z0 : Integer );

var i, j : integer;

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          ph_time[ 0 ] := Random( 5 );
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Ovca;
          SetPhase := SetPhase_Ovca;
          if ( N_TPT < 197 ) and ( Ovca_id = -1 ) then
            begin
              Inc( N_TPT, 4 );
              TPT[ N_TPT-1 ] := LoadTPT_64( 'ovca.tpt' );
              New( TPT[ N_TPT ] );
              for i := 0 to 63 do
                for j := 0 to 63 do
                  TPT[ N_TPT ]^[ i, j ] := TPT[ N_TPT-1 ]^[ i, 63 - j ];
              TPT[ N_TPT-3 ] := LoadTPT_64( 'ovca_dan.tpt' );
              New( TPT[ N_TPT-2 ] );
              for i := 0 to 63 do
                for j := 0 to 63 do
                  TPT[ N_TPT-2 ]^[ i, j ] := TPT[ N_TPT-3 ]^[ i, 63 - j ];
              if TPT[ N_TPT ] = nil then
                begin
                  Dec( N_TPT,4 );
                  Dec( NScene );
                end
              else
                begin
                  Ovca_id := N_TPT;
                end;
            end
          else if Ovca_id = -1 then
            begin
              Dec( N_TPT );
              Dec( NScene );
            end;
          Extend[ 3 ] := Ovca_id;
          Extend[ 2 ] := Ovca_id-1;
          Extend[ 1 ] := Random( 2 );
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

const smesh:word = 0;

procedure DrawMe_Ovca( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      if Extend[ 1 ] = 1 then
        DrawTPT_64( x, y, 0, TPT[ Extend[ 2 ] - smesh ] )
      else
        DrawTPT_64( x, y, 0, TPT[ Extend[ 3 ] - smesh ] );
    end;
end;

procedure SetPhase_Ovca( sprite, phase0 : Integer );

begin
  if not LightOn then
    with Scene[ sprite ] do
      begin
        Smesh := 0;
        if Extend[ 1 ] = 1 then
          begin
            Dec( x, Random( 3 ) );
            if x < 10 then
              Extend[ 1 ] := 2
          end
        else
          begin
            Inc( x, Random( 3 ) );
            if x > 400 then
              Extend[ 1 ] := 1
          end;
      end
  else
    with Scene[ sprite ] do
      begin
        Smesh := 2;
        if Extend[ 1 ] = 1 then
          begin
              Extend[ 1 ] := 2
          end
        else
          begin
              Extend[ 1 ] := 1
          end;
      end
end;

{ ******/ ОБЪЕКТЫ ТИПА ПЛОСКОСТЬ /****** }

const Fill:integer = 1;

procedure Create_Plane( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := Fill;
          ph_time[ 0 ] := 18000;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Plane;
          SetPhase := SetPhase_Plane;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Plane( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( Extend[ 2 ], Extend[ 0 ] );
      Bar( x, y, dx, dy );
      Rectangle( x, y, dx, dy );
    end;
end;

procedure SetPhase_Plane( sprite, phase0 : Integer );

begin
end;

{ ******/ ОБЪЕКТЫ ТИПА КРУГ /****** }

procedure Create_Circle( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := x0;
          Extend[ 3 ] := 639 + dx0;
          ph_time[ 0 ] := 60;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Circle;
          SetPhase := SetPhase_Circle;
          old_time := GetTick;
          Sun := NScene;
          Sun_x0 := x0;
          Sun_y0 := y0;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Circle( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( 1, Extend[ 0 ] );
      FillEllipse( x, y, dx, dy );
      Ellipse( x, y, 0, 359, dx, dy );
    end;
end;

procedure SetPhase_Circle( sprite, phase0 : Integer );

var temp : word;

begin
  if phase0 = 0 then
    with Scene[ sprite ] do
      begin
{        temp := Extend[ 0 ];
        Extend[ 0 ] := Extend[ 1 ];
        Extend[ 1 ] := temp; }
        Inc( x,1 );
        if x > Extend[ 3 ] then
          x := Extend[ 2 ];
          Sun_x0 := x;
          Sun_y0 := y;
      end;
end;


{ ******/ ОБЪЕКТЫ ТИПА ДЫМ /****** }

procedure Create_Fog( x0, y0, dx0, dy0, color, color2, z0 : Integer );

var i : Integer;

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := x0;
          Extend[ 3 ] := y0;
          for i := 0 to 255 do
            ph_time[ i ] := 1;
          phase := 0;
          DrawMe := DrawMe_Fog;
          SetPhase := SetPhase_Fog;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Fog( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( 9, Extend[ 0 ] );
{      Ellipse( x, y, 0, 359, dx, dy );}
      FillEllipse( x, y, dx, dy );
    end;
end;

procedure SetPhase_Fog( sprite, phase0 : Integer );

begin
{  if phase0 = 0 then
    begin
    with Scene[ sprite ] do
      begin
        dx := 1;
        dy := 1;
        x := Extend[ 2 ];
        y := Extend[ 3 ];
      end
    end
  else
    begin }
      with Scene[ sprite ] do
        begin
          Inc( dx, Random( 3 ) );
          Inc( dy, Random( 2 ) );
          if dx > 20 then
            dx := 15;
          if dy > 10 then
            dy := 8;
          Dec( y, Random( 10 ) );
          Inc( x, Random( 8 ) - 5 );
          if y + dx < 0 then
            begin
              dx := 1;
              dy := 1;
              x := Extend[ 2 ];
              y := Extend[ 3 ];
            end
        end;
 {   end;   }
end;


{ ******/ ОБЪЕКТЫ ТИПА ОБЛАКО /****** }

procedure Create_Cloud( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := x0;
          Extend[ 3 ] := y0;
          Extend[ 4 ] := 639 + dx0;
          Extend[ 5 ] := 0;
          ph_time[ 0 ] := 1 + Random( 5 );
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Cloud;
          SetPhase := SetPhase_Cloud;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Cloud( sprite, x0, y0, dx0, dy0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( 1, Extend[ 0 ] );
      Bar( x0, y0, x0 + dx0 shl 1, y0 + dy0);
      Rectangle( x0, y0, x0 + dx0 shl 1, y0 + dy0);
      SetColor( Extend[ 0 ] );
      FillEllipse( x0 + dx0, y0, dx0, dy0 shr 1 );
      FillEllipse( x0, y0 + dy0 shr 1, dx0 shr 1, dy0 shr 1 );
      FillEllipse( x0 + dx0 shl 1, y0 + dy0 shr 1, dx0 shr 1, dy0 shr 1 );
      SetColor( Extend[ 1 ] );
      Ellipse( x0 + dx0, y0, 330, 360+179, dx0, dy0 shr 1 );
      Ellipse( x0, y0 + dy0 shr 1,
               60, 289, dx0 shr 1, dy0 shr 1 );
      Ellipse( x0 + dx0 shl 1, y0 + dy0 shr 1,
               260, 360+89, dx0 shr 1, dy0 shr 1 );
    end;
end;

procedure SetPhase_Cloud( sprite, phase0 : Integer );

begin
  with Scene[ sprite ] do
    begin
      Inc( x,2 );
      if x > Extend[ 4 ] then
        x := Extend[ 2 ];
      if Abs( x + dx - Scene[ Sun ].x ) <
       ( dx*3/2 + Scene[ sun ].dx ) then
{        LightOn := true
      else
        LightOn := false;}
{      if RectIntersect( Sun_x0, Sun_y0, 20, 20,
           x, y, x + dx shl 1, y + dy ) then
        begin
          Line( Sun_x0, Sun_y0, x, y );
          Sound( 500 );
          Delay( 250 );
          NOSound;                             }
        begin
          if Extend[ 5 ] = 0 then
            begin
              Extend[ 5 ] := 1;
              Inc( NumOfCoveredClouds );
              LightOn := true;
            end;
        end
      else if Extend[ 5 ] = 1 then
        begin
          Dec( NumOfCoveredClouds );
          if NumOfCoveredClouds = 0 then
            LightOn := false;
          Extend[ 5 ] := 0;
        end;
      {      }
    end;
end;

{ ******/ ОБЪЕКТЫ ТИПА СОСУЛЬКА /****** }

const Sosulka : integer = -1;
      Kaplja  : integer = -1;
      Kaplja_drop: boolean = false;
      Is_Sosulka : boolean = true;

procedure Create_Sosulka( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := x0;
          Extend[ 3 ] := y0;
          Extend[ 4 ] := x0 + 5;
          Extend[ 5 ] := y0 + 15;
          Extend[ 6 ] := x0 + 10;
          Extend[ 7 ] := y0;
          Extend[ 8 ] := 1;
          ph_time[ 0 ] := 20;
          ph_time[ 1 ] := 20;
          ph_time[ 2 ] := 20;
          ph_time[ 3 ] := 0;
          ph_time[ 4 ] := 50;
          ph_time[ 5 ] := 50;
          ph_time[ 6 ] := 50;
          ph_time[ 7 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Sosulka;
          SetPhase := SetPhase_Sosulka;
          old_time := GetTick;
        end;
      if Sosulka = -1 then
        Sosulka := NScene;
      Create_Kaplja( x0+5, y0+15, 3, 3, Blue, LightBlue, z0 );
      if Kaplja = -1 then
        Kaplja := NScene;
      if Kaplja = Sosulka then
        Kaplja := -1;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Sosulka( sprite, x0, y0, dx0, dy0 : Integer );

begin
  DrawMe_Top( sprite, x0, y0, dx0, dy0 );
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( Extend[ 2 ], Extend[ 0 ] );
      FillEllipse( 170, 340, 150 - Extend[ 5 ] + y, 20 );
{      Ellipse( 145, 340, 0, 359, 150 - Extend[ 5 ]+y, 20 );}
    end
end;

procedure SetPhase_Sosulka( sprite, phase0 : Integer );

begin
  if Kaplja_Drop and Is_Sosulka then
    begin
      with Scene[ sprite ] do
        begin
          Dec( Extend[ 5 ] );
          Kaplja_Drop := false;
          if Extend[ 5 ] < y then
            begin
              Extend[ 5 ] := y;
              Is_Sosulka := false;
            end;
        end;
    end
  else if not Is_Sosulka then
    begin
      with Scene[ sprite ] do
        begin
          Inc( Extend[ 5 ] );
          if Extend[ 5 ] > y + 15 then
            begin
              Extend[ 5 ] := y + 15;
              Is_Sosulka := true;
              Scene[ Kaplja ].y := Extend[ 5 ];
            end;
        end;
    end;
end;

{ ******/ ОБЪЕКТЫ ТИПА ОЗЕРО /****** }

procedure Create_Ozero( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
end;

procedure DrawMe_Ozero( sprite, x0, y0, dx0, dy0 : Integer );

begin
end;

procedure SetPhase_Ozero( sprite, phase0 : Integer );

begin
end;


{ ******/ ОБЪЕКТЫ ТИПА КАПЛЯ /****** }

procedure Create_Kaplja( x0, y0, dx0, dy0, color, color2, z0 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := 1;
          Extend[ 3 ] := 3;
          ph_time[ 0 ] := 1;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Kaplja;
          SetPhase := SetPhase_Kaplja;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Kaplja( sprite, x0, y0, dx0, dy0 : Integer );

begin
  if Is_Sosulka then
    with Scene[ sprite ] do
      begin
        SetColor( Extend[ 1 ] );
        SetFillStyle( Extend[ 2 ], Extend[ 0 ] );
        FillEllipse( x, y, dx, dy );
        Ellipse( x, y, 0, 359, dx, dy );
      end
  else if not Kaplja_Drop then
    with Scene[ sprite ] do
      begin
        SetColor( Extend[ 1 ] );
        SetFillStyle( Extend[ 2 ], Extend[ 0 ] );
        FillEllipse( x, y, dx, dy );
        Ellipse( x, y, 0, 359, dx, dy );
      end
end;

const Ground_Level = 340;

procedure SetPhase_Kaplja( sprite, phase0 : Integer );

begin
  If Is_Sosulka then
    begin
      with Scene[ sprite ] do
        begin
          Inc( y,5 );
          if y > Ground_Level then
            begin
              y := Scene[ Sosulka ].Extend[ 5 ];
              Kaplja_Drop := true;
            end;
        end;
    end
  else if not Kaplja_Drop then
    begin
      with Scene[ sprite ] do
        begin
          Inc( y,5 );
          if y > Ground_Level then
            begin
              y := Scene[ Sosulka ].Extend[ 5 ];
              Kaplja_Drop := true;
            end;
        end;
    end
end;


{ ******/ ОБЪЕКТЫ ТИПА КРЫША /****** }

procedure Create_Top( x0, y0, dx0, dy0, color, color2, z0,
                      x1, y1,
                      x2, y2 : Integer );

begin
  Inc( NScene );
  if NScene < MAX_OBJECTS + 1 then
    begin
      with Scene[ NScene ] do
        begin
          x := x0;
          y := y0;
          z := z0;
          dx := dx0;
          dy := dy0;
          Extend[ 0 ] := color2;
          Extend[ 1 ] := color;
          Extend[ 2 ] := x0;
          Extend[ 3 ] := y0;
          Extend[ 4 ] := x1;
          Extend[ 5 ] := y1;
          Extend[ 6 ] := x2;
          Extend[ 7 ] := y2;
          Extend[ 8 ] := 4;
          ph_time[ 0 ] := 18000;
          ph_time[ 1 ] := 0;
          phase := 0;
          DrawMe := DrawMe_Top;
          SetPhase := SetPhase_Top;
          old_time := GetTick;
        end;
    end
  else
    Dec( NScene );
end;

procedure DrawMe_Top( sprite, x0, y0, dx0, dy0 : Integer );

var arr : array [ 0..3 ] of PointType;
      i : Integer;

begin
  for i := 0 to 3 do
    with Scene[ sprite ] do
      begin
        arr[ i mod 3 ].X := Extend[ 2*(i mod 3 ) + 2 ];
        arr[ i mod 3 ].Y := Extend[ 2*(i mod 3 ) + 3 ];
      end;
  with Scene[ sprite ] do
    begin
      SetColor( Extend[ 1 ] );
      SetFillStyle( Extend[ 8 ], Extend[ 0 ] );
      DrawPoly( 3, arr );
      FillPoly( 3, arr );
    end;
end;

procedure SetPhase_Top( sprite, phase0 : Integer );

begin
end;


{ ******/ ОБЪЕКТЫ ТИПА ДОМИК /****** }

procedure Create_House( x0, y0, z0 : Integer );

var i : Integer;

begin
  Create_Top( x0, y0, 0, 0, LightGray, Brown, z0,
              x0 + 150, y0 - 150,
              x0 + 300, y0  );
  Create_Plane( x0+40, y0-70, x0+60, y0, Red, Red, z0 + 1 );
  Create_Plane( x0+30, y0-80, x0+70, y0-70, Red, Red, z0 + 1 );
  Create_Plane( x0+30, y0+1, x0+270, y0+150, Brown, Brown, z0 + 1 );
  Create_Plane( x0+20, y0+150, x0+280, y0+160, Red, Red, z0 + 1 );
  for i := 1 to 50 do
    begin
      Create_Fog( x0+55, y0-70, 0, 0, Black, LightGray, z0 + 2 );
      Scene[ NScene ].phase := Random( 255 );
    end;
  Fill := 4;
  Create_Plane( x0+180, y0+40, x0+250, y0+140, Red, LightGray, z0 + 1 );
  Fill := 1;
  Create_Plane( x0+50, y0+50, x0+150, y0+100, Red, 0, z0 + 1 );
  Create_Plane( x0+52, y0+52, x0+108, y0+98, Red, LightBlue, z0 + 1 );
  Create_Plane( x0+110, y0+52, x0+148, y0+74, Red, LightBlue, z0 + 1 );
  Create_Plane( x0+110, y0+76, x0+148, y0+98, Red, Blue, z0 + 1 );
end;

procedure DrawMe_House( sprite, x0, y0, dx0, dy0 : Integer );

begin
end;

procedure SetPhase_House( sprite, phase0 : Integer );

begin
end;


end.