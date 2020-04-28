program MouseTest;

uses Vga, Mouse, Crt, File_LIB;

var color : Integer;
    i,
    j     : Integer;
    x0,
    y0    : Integer;
    Pic   : TPT_64x64;
    Name  : String;

const
  m_x = 100;
  m_y = 100;

procedure InitMainScreen;

begin
 x0 := 0;
 y0 := 0;
 color := 0;
 for I := 0 to 255 do
   begin
     Line( x0, y0, x0 + 5, y0, I );
     Line( x0, y0+1, x0 + 5, y0+1, I );
     Line( x0, y0+2, x0 + 5, y0+2, I );
     Line( x0, y0+3, x0 + 5, y0+3, I );
     Line( x0, y0+4, x0 + 5, y0+4, I );
     x0 := x0 + 6;
     color := color + 1;
     if color = 8 then
       begin
         x0 := 0;
         y0 := y0 + 5;
         color := 0;
       end;
   end;
 Line( m_x-1, m_y-1, m_x + 64, m_y - 1, 15 );
 Line( m_x + 64, m_y-1, m_x + 64, m_y + 64, 15 );
 Line( m_x-1, m_y + 64, m_x + 64, m_y + 64, 15 );
 Line( m_x-1, m_y-1, m_x -1, m_y + 64, 15 );

 Line( 50, 190, 70, 190, 15 );
 Line( 50, 195, 70, 195, 15 );

 Line( 80, 190, 100, 190, 15 );
 Line( 80, 195, 100, 195, 15 );
end;

begin
 ScreenMode( $13 );
 { $I- }
 x0 := 0;
 y0 := 0;
 color := 0;
 New( Pic );
 InitMainScreen;
 ReadLn;
 if InitMouse then
   begin
     MoveTo( 160, 100 );
     ShowMouse;
     repeat
       if MousePressed then
         begin
           MoveTo( MouseWhereX div 2, MouseWhereY );
           HideMouse;
           if MouseIn( 0, 0, 95, 154 ) then
             begin
               color := GetDot( MouseWhereX div 2, MouseWhereY );
               Line( 59, 10, 79, 10, color );
               Line( 59, 11, 79, 11, color );
               Line( 59, 12, 79, 12, color );
               Line( 59, 13, 79, 13, color );
               Line( 59, 14, 79, 14, color );
             end
           else if MouseIn( 100, 190, 140, 195 ) then
             begin
               Line( 50, 190, 70, 190, color );
               Line( 50, 195, 70, 195, color );
               for I := 0 to 63 do
                 for J := 0 to 63 do
                   Pic^[ J, I ] := GetDot( I+m_x, J+m_y );
               ScreenMode( 3 );
               WriteLn( 'Введите имя сохраняемого файла:' );
               ReadLn( Name );
               ScreenMode( $13 );
               InitMainScreen;
               SaveTPT_64( Name, Pic );
               X_DrawTPT_64( m_x, m_y, Pic )
             end
           else if MouseIn( 160, 190, 200, 195 ) then
             begin
               Line( 80, 190, 100, 190, color );
               Line( 80, 195, 100, 195, color );
               ScreenMode( 3 );
               WriteLn( 'Введите имя загружаемого файла:' );
               ReadLn( Name );
               ScreenMode( $13 );
               InitMainScreen;
               Pic := LoadTPT_64( Name );
               X_DrawTPT_64( m_x, m_y, Pic )
             end
           else
             while MousePressed
              and MouseIn( m_x shl 1, m_y,
                          (m_x + 63) shl 1, m_y + 63 ) do
               LineTo( MouseWhereX div 2, MouseWhereY, color );
           ShowMouse;
         end;
     until KeyPressed;
     HideMouse;
   end
 else
   Sound( 500 );
 { $I+ }
 if Pic <> nil then
   Dispose( Pic );
 ScreenMode( 3 );
end.