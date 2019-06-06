unit RGBCIEUtils;

interface

uses
  System.SysUtils,
  System.Math,
  Winapi.Windows,
  Vcl.Graphics;

const
  { // Observer= 2°, Illuminant= D65    - Daylignt
    ref_X =  95.047;
    ref_Z = 108.883;
    // Observer= 10°, Illuminant= D65   - Daylight
    ref_X =  94.811;
    ref_Z = 35.2;

    // Observer= 2°, Illuminant= A      - Incadescent
    ref_X =  109.850;
    ref_Z = 35.585;
    // Observer= 10°, Illuminant= A     - Incadescent
    ref_X =  111.144;
    ref_Z = 35.2;

    // Observer= 2°, Illuminant= C
    ref_X =  98.074;
    ref_Z = 118.232;
    // Observer= 10°, Illuminant= C
    ref_X =  97.285;
    ref_Z = 116.145;
  }
  // Observer= 2°, Illuminant= D50
  ref_X = 96.422;
  ref_Z = 82.521; {
    // Observer= 10°, Illuminant= D50 - Photoshop
    ref_X =  96.72;
    ref_Z = 81.427; }

  { // Observer= 2°, Illuminant= D55
    ref_X =  95.682;
    ref_Z = 92.149;
    // Observer= 10°, Illuminant= D55
    ref_X =  95.799;
    ref_Z = 90.926;

    // Observer= 2°, Illuminant= D75
    ref_X =  94.972;
    ref_Z = 122.638;
    // Observer= 10°, Illuminant= D75
    ref_X =  94.416;
    ref_Z = 12.641;

    // Observer= 2°, Illuminant= F2     - Fluorescent
    ref_X =  99.187;
    ref_Z = 67.395;
    // Observer= 10°, Illuminant= F2    - Fluorescent
    ref_X =  103.28;
    ref_Z = 69.026;

    // Observer= 2°, Illuminant= F7
    ref_X =  95.044;
    ref_Z = 108.755;
    // Observer= 10°, Illuminant= F7
    ref_X =  95.792;
    ref_Z = 107.678;

    // Observer= 2°, Illuminant= F11
    ref_X =  100.966;
    ref_Z = 64.370;
    // Observer= 10°, Illuminant= F11
    ref_X =  103.866;
    ref_Z = 65.627; }

type
  xyz = record
    x: Real;
    y: Real;
    z: Real;
  end;

function GetCIEAValue(c: TColor): Real;
function GetCIEBValue(c: TColor): Real;
function GetCIECValue(c: TColor): Real;
function GetCIEHValue(c: TColor): Real;
function GetCIELValue(c: TColor): Real;
function GetCIEXValue(c: TColor): Real;
function GetCIEYValue(c: TColor): Real;
function GetCIEZValue(c: TColor): Real;
function LabToRGB(l, a, b: Real): TColor;
function LabToXYZ(l, a, b: Real): xyz;
function LCHToRGB(l, c, h: Real): TColor;
function RGBToXYZ(c: TColor): xyz; overload;
function RGBToXYZ(r, g, b: Byte): xyz; overload;
function XYZToRGB(space: xyz): TColor;
procedure LabToLCH(l, a, b: Real; var lum, c, h: Real);
procedure LCHToLab(lum, c, h: Real; var l, a, b: Real);
procedure RGBToLab(_r, _g, _b: Byte; var l, a, b: Real); overload;
procedure RGBToLab(clr: TColor; var l, a, b: Real); overload;
procedure RGBToLCH(_r, _g, _b: Byte; var l, c, h: Real); overload;
procedure RGBToLCH(clr: TColor; var l, c, h: Real); overload;
procedure XYZToLab(space: xyz; var l, a, b: Real);

implementation

function LabToXYZ(l, a, b: Real): xyz;
var
  x, y, z: Real;
begin
  y := (l + 16) / 116;
  x := a / 500 + y;
  z := y - b / 200;
  if y > 0.2069 then
    y := IntPower(y, 3)
  else
    y := (y - 0.138) / 7.787;
  if x > 0.2069 then
    x := IntPower(x, 3)
  else
    x := (x - 0.138) / 7.787;
  if z > 0.2069 then
    z := IntPower(z, 3)
  else
    z := (z - 0.138) / 7.787;
  Result.x := ref_X * x;
  Result.y := 100 * y;
  Result.z := ref_Z * z;
end;

function XYZToRGB(space: xyz): TColor;
var
  r, g, b, x, y, z: Real;
begin
  x := space.x / 100;
  y := space.y / 100;
  z := space.z / 100;
  r := x * 3.2406 + y * (-1.5372) + z * (-0.49);
  g := x * (-0.969) + y * 1.8758 + z * 0.0415;
  b := x * 0.0557 + y * (-0.2040) + z * 1.0570;
  if r > 0.00313 then
    r := 1.055 * Power(r, 1 / 2.4) - 0.055
  else
    r := 12.92 * r;
  if g > 0.00313 then
    g := 1.055 * Power(g, 1 / 2.4) - 0.055
  else
    g := 12.92 * g;
  if b > 0.00313 then
    b := 1.055 * Power(b, 1 / 2.4) - 0.055
  else
    b := 12.92 * b;

  if r < 0 then
    r := 0;
  if r > 1 then
    r := 1;
  if g < 0 then
    g := 0;
  if g > 1 then
    g := 1;
  if b < 0 then
    b := 0;
  if b > 1 then
    b := 1;
  Result := RGB(Round(r * 255), Round(g * 255), Round(b * 255));
end;

function LabToRGB(l, a, b: Real): TColor;
begin
  Result := XYZToRGB(LabToXYZ(l, a, b));
end;

function RGBToXYZ(c: TColor): xyz;
var
  r, g, b: Real;
begin
  r := GetRValue(c) / 255;
  g := GetGValue(c) / 255;
  b := GetBValue(c) / 255;
  if r > 0.04045 then
    r := Power((r + 0.055) / 1.055, 2.4)
  else
    r := r / 12.92;
  if g > 0.04045 then
    g := Power((g + 0.055) / 1.055, 2.4)
  else
    g := g / 12.92;
  if b > 0.04045 then
    b := Power((b + 0.055) / 1.055, 2.4)
  else
    b := b / 12.92;
  r := r * 100;
  g := g * 100;
  b := b * 100;
  // Observer= 2°, Illuminant= D65
  Result.x := r * 0.4124 + g * 0.3576 + b * 0.1805;
  Result.y := r * 0.2126 + g * 0.7152 + b * 0.0722;
  Result.z := r * 0.0193 + g * 0.1192 + b * 0.9505;
end;

function RGBToXYZ(r, g, b: Byte): xyz; overload;
var
  r1, g1, b1: Real;
begin
  r1 := r / 255;
  g1 := g / 255;
  b1 := b / 255;
  if r1 > 0.04045 then
    r1 := Power((r1 + 0.055) / 1.055, 2.4)
  else
    r1 := r1 / 12.92;
  if g1 > 0.04045 then
    g1 := Power((g1 + 0.055) / 1.055, 2.4)
  else
    g1 := g1 / 12.92;
  if b1 > 0.04045 then
    b1 := Power((b1 + 0.055) / 1.055, 2.4)
  else
    b1 := b1 / 12.92;
  r1 := r1 * 100;
  g1 := g1 * 100;
  b1 := b1 * 100;
  // Observer= 2°, Illuminant= D65
  Result.x := r1 * 0.4124 + g1 * 0.3576 + b1 * 0.1805;
  Result.y := r1 * 0.2126 + g1 * 0.7152 + b1 * 0.0722;
  Result.z := r1 * 0.0193 + g1 * 0.1192 + b1 * 0.9505;
end;

procedure XYZToLab(space: xyz; var l, a, b: Real);
var
  x, y, z: Real;
begin
  x := space.x / ref_X;
  y := space.y / 100;
  z := space.z / ref_Z;
  if x > 0.008856 then
    x := Power(x, 1 / 3)
  else
    x := (7.787 * x) + 0.138;
  if y > 0.008856 then
    y := Power(y, 1 / 3)
  else
    y := (7.787 * y) + 0.138;
  if z > 0.008856 then
    z := Power(z, 1 / 3)
  else
    z := (7.787 * z) + 0.138;
  l := (116 * y) - 16;
  a := 500 * (x - y);
  b := 200 * (y - z);
  if l > 100 then
    l := 100;
  if l < 0 then
    l := 0;
  if a < -128 then
    a := -128;
  if a > 127 then
    a := 127;
  if b < -128 then
    b := -128;
  if b > 127 then
    b := 127;
end;

procedure RGBToLab(clr: TColor; var l, a, b: Real);
var
  s: xyz;
begin
  s := RGBToXYZ(clr);
  XYZToLab(s, l, a, b);
end;

procedure RGBToLab(_r, _g, _b: Byte; var l, a, b: Real); overload;
var
  s: xyz;
begin
  s := RGBToXYZ(_r, _g, _b);
  XYZToLab(s, l, a, b);
end;

procedure LCHToLab(lum, c, h: Real; var l, a, b: Real);
begin
  l := lum;
  a := cos(DegToRad(h)) * c;
  b := sin(DegToRad(h)) * c;
end;

procedure LabToLCH(l, a, b: Real; var lum, c, h: Real);
begin
  h := ArcTan2(b, a);
  if h > 0 then
    h := (h / PI) * 180
  else
    h := 360 - (ABS(h) / PI) * 180;
  lum := l;
  c := SQRT(a * a + b * b);
end;

procedure RGBToLCH(clr: TColor; var l, c, h: Real);
var
  a, b: Real;
begin
  RGBToLab(clr, l, a, b);
  LabToLCH(l, a, b, l, c, h);
end;

procedure RGBToLCH(_r, _g, _b: Byte; var l, c, h: Real);
var
  a, b: Real;
begin
  RGBToLab(_r, _g, _b, l, a, b);
  LabToLCH(l, a, b, l, c, h);
end;

function LCHToRGB(l, c, h: Real): TColor;
var
  lum, a, b: Real;
begin
  LCHToLab(l, c, h, lum, a, b);
  Result := LabToRGB(lum, a, b);
end;

function GetCIEXValue(c: TColor): Real;
var
  d: xyz;
begin
  d := RGBToXYZ(c);
  Result := d.x;
end;

function GetCIEYValue(c: TColor): Real;
var
  d: xyz;
begin
  d := RGBToXYZ(c);
  Result := d.y;
end;

function GetCIEZValue(c: TColor): Real;
var
  d: xyz;
begin
  d := RGBToXYZ(c);
  Result := d.z;
end;

function GetCIELValue(c: TColor): Real;
var
  d: Real;
begin
  XYZToLab(RGBToXYZ(c), Result, d, d);
end;

function GetCIEAValue(c: TColor): Real;
var
  d: Real;
begin
  XYZToLab(RGBToXYZ(c), d, Result, d);
end;

function GetCIEBValue(c: TColor): Real;
var
  d: Real;
begin
  XYZToLab(RGBToXYZ(c), d, d, Result);
end;

function GetCIECValue(c: TColor): Real;
var
  d: Real;
begin
  RGBToLCH(c, d, Result, d);
end;

function GetCIEHValue(c: TColor): Real;
var
  d: Real;
begin
  RGBToLCH(c, d, d, Result);
end;

end.
