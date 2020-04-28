unit Vga;

interface

  procedure ScreenMode(m : word);
  { устанавливает режим экрана }
  procedure Dot(x, y : integer; c : byte);
  { рисует точку }
  procedure Line( x1, y1, x2, y2 : integer; c : byte );
  { рисует линию }
  function GetDot(x,y : integer) : byte;
  { определяет цвет точки }
  procedure LineTo( x, y : integer; c : byte );

  procedure MoveTo( x, y : integer );

implementation

  uses Dos;

  procedure ScreenMode(m : word);

  var r : registers;

  begin
    r.ax := m;
    intr($10,r);
  end;

  procedure Dot(x, y : integer; c : byte);

  begin
    if ( x >= 0) and ( x < 320 ) and ( y >= 0 ) and ( y < 200 ) then
      mem[$A000:y*320+x] := c;
  end;

  function GetDot(x, y : integer) : byte;

  begin
    GetDot := mem[$A000:320*y + x];
  end;

  procedure Line( x1, y1, x2, y2 : integer; c : byte );

  var dx, dy, sx, sy, d, d1, d2, x, y, i : integer;

  begin
    dx := abs( x2 - x1 );
    dy := abs( y2 - y1 );
    if x2 >= x1 then
      sx := 1
    else
      sx := -1;
    if y2 >= y1 then
      sy := 1
    else
      sy := -1;
    if dy <= dx then
      begin
        d := dy * 2 - dx;
        d1 := dy * 2;
        d2 := ( dy - dx ) * 2;
        Dot( x1, y1, c );
        x := (x1+sx);
        y := y1;
        for i := 1 to dx do
          begin
            if d > 0 then
              begin
                inc( d, d2 );
                inc( y, sy )
              end
            else
              inc( d, d1 );
            Dot( x, y, c );
            inc( x, sx );
          end;
      end;
    if dy > dx then
      begin
        d := (dx * 2 ) - dy;
        d1 := dx * 2;
        d2 := ( dx - dy ) * 2;
        Dot( x1, y1, c );
        y := (y1+sy);
        x := x1;
        for i := 1 to dy do
          begin
            if d > 0 then
              begin
                inc( d, d2 );
                inc( x, sx )
              end
            else
              inc( d, d1 );
            Dot( x, y, c );
            inc( y, sy );
          end;
        end
  end;

var x0, y0 : Integer;

procedure LineTo( x, y : integer; c : byte );

begin
  Line( x0, y0, x, y, c );
  x0 := x;
  y0 := y
end;

procedure MoveTo( x, y : integer );

begin
  x0 := x;
  y0 := y;
end;

begin
  x0 := 0;
  y0 := 0;
end.