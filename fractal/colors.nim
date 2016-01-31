import tables
import math

proc naive(x, y, precolor: float): uint32 {.procvar.} =
  let f = 4095.0 * precolor
  let c = (4095-f.int) shl 12 or f.int
  return 0xFF000000'u32 + c.uint32


proc gray(x, y, precolor: float): uint32 {.procvar.} =
  let f = 255.0 - 255.0 * precolor
  let c = f.int shl 16 + f.int shl 8 + f.int
  return 0xFF000000'u32 + c.uint32


type
  RGBColor = tuple[r: float, g: float, b: float]
var
  rainbow: array[0..6, RGBColor]

rainbow[0] = (r: 209.0, g: 0.0,   b: 0.0)
rainbow[1] = (r: 255.0, g: 102.0, b: 34.0)
rainbow[2] = (r: 255.0, g: 218.0, b: 33.0)
rainbow[3] = (r: 51.0,  g: 221.0, b: 0.0)
rainbow[4] = (r: 17.0,  g: 51.0,  b: 204.0)
rainbow[5] = (r: 34.0,  g: 0.0,   b: 102.0)
rainbow[6] = (r: 51.0,  g: 0.0,   b: 68.0)

proc roygbiv(x, y, precolor: float): uint32 {.procvar.} =
  let ff = 7.0 * precolor
  var n = ff.int
  var f = ff - n.float

  if n == 7:
    return 0
  if n mod 2 != 1:
    f = 1.0 - f

  var
    r = (rainbow[n].r * f).int
    g = (rainbow[n].g * f).int
    b = (rainbow[n].b * f).int
    c = (r shl 16) or (g shl 8) or b
  return 0xFF000000'u32 + c.uint32


proc onthesea(x, y, precolor: float): uint32 {.procvar.} =
  var r, g, b: float
  var f = 1.5 * log10(precolor*1000) / log10(1000)
  if f > 1.0:
    f = 1.0
  f = 1.0 - f
  if (abs(y) < 0.0001):
    return 0
  elif (y < 0):
    r = 255.0 * f
    g = 51.0 * f
    b = 51.0 * f
  else:
    r = 48.0 * f
    g = 48.0 * f
    b = 255.0 * f
  var c = (r.int shl 16) or (g.int shl 8) or b.int
  return 0xFF000000'u32 + c.uint32

var
  colorFunc* = {
    "naive": naive,
    "gray": gray,
    "roygbiv": roygbiv,
    "onthesea": onthesea,
  }.toTable

# vim: ts=2 sts=2 sw=2 expandtab:
