unit File_LIB;

{$I-}

{*----------------*}
{*}  interface   {*}
{*----------------*}

uses Crt, Graph, Vga;

type
  PictureType_64x64 = array [ 0..63, 0..63 ] of Byte;
  PictureType_32x32 = array [ 0..31, 0..31 ] of Byte;
  PictureType_16x16 = array [ 0..15, 0..15 ] of Byte;
  PictureType_8x8 = array [ 0..7, 0..7 ] of Byte;

  TPT_64x64 = ^PictureType_64x64;
  TPT_32x32 = ^PictureType_32x32;
  TPT_16x16 = ^PictureType_16x16;
  TPT_8x8 = ^PictureType_8x8;

  FPT_64x64 = file of PictureType_64x64;
  FPT_32x32 = file of PictureType_32x32;
  FPT_16x16 = file of PictureType_16x16;
  FPT_8x8 = file of PictureType_8x8;


function LoadTPT_64( name : String ) : TPT_64x64;

function LoadTPT_32( name : String ) : TPT_32x32;

function LoadTPT_16( name : String ) : TPT_16x16;

function LoadTPT_8( name : String ) : TPT_8x8;


procedure SaveTPT_64( name : String; s : TPT_64x64 );

procedure SaveTPT_32( name : String; s : TPT_32x32 );

procedure SaveTPT_16( name : String; s : TPT_16x16 );

procedure SaveTPT_8( name : String; s : TPT_8x8 );


procedure DrawTPT_64( x, y, c : Word; pic : TPT_64x64 );

procedure DrawTPT_32( x, y, c : Word; pic : TPT_32x32 );

procedure DrawTPT_16( x, y, c : Word; pic : TPT_16x16 );

procedure DrawTPT_8( x, y, c : Word; pic : TPT_8x8 );


procedure X_DrawTPT_64( x, y : Word; pic : TPT_64x64 );

procedure X_DrawTPT_32( x, y : Word; pic : TPT_32x32 );

procedure X_DrawTPT_16( x, y : Word; pic : TPT_16x16 );

procedure X_DrawTPT_8( x, y : Word; pic : TPT_8x8 );


{*--------------------*}
{*}  implementation  {*}
{*--------------------*}


function LoadTPT_64( name : String ) : TPT_64x64;

var Pic : TPT_64x64;
    F   : FPT_64x64;

begin
  new( Pic );
  if Pic <> nil then
    begin
      Assign( F, Name );
      Reset( F );
      Read( F, Pic^ );
      Close( F );
      if IOResult <> 0 then
        begin
          Dispose( Pic );
          Pic := nil;
        end;
    end;
  LoadTPT_64 := Pic;
end;

function LoadTPT_32( name : String ) : TPT_32x32;

var Pic : TPT_32x32;
    F   : FPT_32x32;

begin
  new( Pic );
  if Pic <> nil then
    begin
      Assign( F, Name );
      Reset( F );
      Read( F, Pic^ );
      Close( F );
      if IOResult <> 0 then
        begin
          Dispose( Pic );
          Pic := nil;
        end;
    end;
  LoadTPT_32 := Pic;
end;

function LoadTPT_16( name : String ) : TPT_16x16;

var Pic : TPT_16x16;
    F   : FPT_16x16;

begin
  new( Pic );
  if Pic <> nil then
    begin
      Assign( F, Name );
      Reset( F );
      Read( F, Pic^ );
      Close( F );
      if IOResult <> 0 then
        begin
          Dispose( Pic );
          Pic := nil;
        end;
    end;
  LoadTPT_16 := Pic;
end;

function LoadTPT_8( name : String ) : TPT_8x8;

var Pic : TPT_8x8;
    F   : FPT_8x8;

begin
  new( Pic );
  if Pic <> nil then
    begin
      Assign( F, Name );
      Reset( F );
      Read( F, Pic^ );
      Close( F );
      if IOResult <> 0 then
        begin
          Dispose( Pic );
          Pic := nil;
        end;
    end;
  LoadTPT_8 := Pic;
end;

procedure SaveTPT_64( name : String; s : TPT_64x64 );

var
  F   : FPT_64x64;

begin
  Assign( F, Name );
  Rewrite( F );
  Write( F, s^ );
  Close( F );
end;

procedure SaveTPT_32( name : String; s : TPT_32x32 );

var
  F   : FPT_32x32;

begin
  Assign( F, Name );
  Rewrite( F );
  Write( F, s^ );
  Close( F );
end;

procedure SaveTPT_16( name : String; s : TPT_16x16 );

var
  F   : FPT_16x16;

begin
  Assign( F, Name );
  Rewrite( F );
  Write( F, s^ );
  Close( F );
end;

procedure SaveTPT_8( name : String; s : TPT_8x8 );

var
  F   : FPT_8x8;

begin
  Assign( F, Name );
  Rewrite( F );
  Write( F, s^ );
  Close( F );
end;

const offs = 0; {640*400;  }

var i, j, k : word;
    x0, y0, dx, dy : word;

procedure DrawTPT_64( x, y, c : Word; pic : TPT_64x64 );

begin
  if x >= 0 then
    x0 := x
  else
    x0 := 0;
  if y >= 0 then
    y0 := y
  else
    y0 := 0;
  if x >= 640 then
    pic := nil;
  if y >= 400 then
    pic := nil;
  if x + 64 <= 640 then
    dx := 63
  else
    dx := 640 - x;
  if y + 64 <= 400 then
    dy := 63
  else
    dy := 400 - y;
  if Pic <> nil then
    for j := y0 to dy + y do
      for i := x0 to dx + x do
        begin
          k := Pic^[ j-y, i-x ];
          if k <> c then
            PutPixel( i, j, k );
{            Mem[ $A000:offs + 640*j + i ] := k;}
        end;
end;

procedure DrawTPT_32( x, y, c : Word; pic : TPT_32x32 );

begin
  if x >= 0 then
    x0 := x
  else
    x0 := 0;
  if y >= 0 then
    y0 := y
  else
    y0 := 0;
  if x >= 640 then
    pic := nil;
  if y >= 400 then
    pic := nil;
  if x + 32 <= 640 then
    dx := 31
  else
    dx := 640 - x;
  if y + 32 <= 400 then
    dy := 31
  else
    dy := 400 - y;
  if Pic <> nil then
    for j := y0 to dy + y do
      for i := x0 to dx + x do
        begin
          k := Pic^[ j-y, i-x ];
          if k <> c then
            PutPixel( i, j, k );
{            Mem[ $A000:offs + 640*j + i ] := k;}
        end;
end;

procedure DrawTPT_16( x, y, c : Word; pic : TPT_16x16 );

begin
  if x >= 0 then
    x0 := x
  else
    x0 := 0;
  if y >= 0 then
    y0 := y
  else
    y0 := 0;
  if x >= 640 then
    pic := nil;
  if y >= 400 then
    pic := nil;
  if x + 16 <= 640 then
    dx := 15
  else
    dx := 640 - x;
  if y + 16 <= 400 then
    dy := 15
  else
    dy := 400 - y;
  if Pic <> nil then
    for j := y0 to dy + y do
      for i := x0 to dx + x do
        begin
          k := Pic^[ j-y, i-x ];
          if k <> c then
            PutPixel( i, j, k );
{            Mem[ $A000:offs + 640*j + i ] := k;}
        end;
end;

procedure DrawTPT_8( x, y, c : Word; pic : TPT_8x8 );

begin
  if x >= 0 then
    x0 := x
  else
    x0 := 0;
  if y >= 0 then
    y0 := y
  else
    y0 := 0;
  if x >= 640 then
    pic := nil;
  if y >= 400 then
    pic := nil;
  if x + 8 <= 640 then
    dx := 7
  else
    dx := 640 - x;
  if y + 8 <= 400 then
    dy := 7
  else
    dy := 400 - y;
  if Pic <> nil then
    for j := y0 to dy + y do
      for i := x0 to dx + x do
        begin
          k := Pic^[ j-y, i-x ];
          if k <> c then
            PutPixel( i, j, k );
{            Mem[ $A000:offs + 640*j + i ] := k;}
        end;
end;


procedure X_DrawTPT_64( x, y : Word; pic : TPT_64x64 );

begin
  for j := y to 63 + y do
    for i := x to 63 + x do
      begin
        k := Pic^[ j-y, i-x ];
        Mem[ $A000:320*j + i ] := k;
      end;
end;

procedure X_DrawTPT_32( x, y : Word; pic : TPT_32x32 );

begin
  for j := y to 31 + y do
    for i := x to 31 + x do
      begin
        k := Pic^[ j-y, i-x ];
        Mem[ $A000:320*j + i ] := k;
      end;
end;

procedure X_DrawTPT_16( x, y : Word; pic : TPT_16x16 );

begin
  for j := y to 15 + y do
    for i := x to 15 + x do
      begin
        k := Pic^[ j-y, i-x ];
        Mem[ $A000:320*j + i ] := k;
      end;
end;

procedure X_DrawTPT_8( x, y : Word; pic : TPT_8x8 );

begin
  for j := y to 7 + y do
    for i := x to 7 + x do
      begin
        k := Pic^[ j-y, i-x ];
        Mem[ $A000:320*j + i ] := k;
      end;
end;

end.