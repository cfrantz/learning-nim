import sdl2


proc getPixelPointer*(surface: SurfacePtr): ptr uint32 =
  return cast[ptr uint32](surface.pixels)


proc getPixelPointer*(window: WindowPtr): ptr uint32 =
  return getPixelPointer(getSurface(window))

# Create array-like operators for "ptr uint32" to make accessing the
# pixel data eaiser.  This is both dangerous and depends on the color
# model of the pixel data being ARGB, but it's fast compared to something
# like sdl2.gfx.pixelColor().
proc `[]`*(p: ptr uint32, offset: int): uint32 =
  let p1 = cast[int64](p) + offset * 4
  let p2 = cast[ptr uint32](p1)
  return p2[]


proc `[]=`*(p: ptr uint32, offset: int, value: uint32): void =
  let p1 = cast[int64](p) + offset * 4
  let p2 = cast[ptr uint32](p1)
  p2[] = value


proc maybeSwap*(x0, x1: var int): void =
  if (x1 < x0):
    var t = x0
    x0 = x1
    x1 = t


# Draw a square on the display by XORing agains the color that's already
# displayed.
proc drawSquareXor*(window: WindowPtr, px0, py0, px1, py1: int): void =
  var
    surface = getSurface(window)
    p = getPixelPointer(surface)
    stride = surface.pitch div 4
    x0 = px0
    y0 = py0
    x1 = px1
    y1 = py1

  maybeSwap(x0, x1)
  maybeSwap(y0, y1)

  var
    x = x0
    y = y0+1

  while x <= x1:
    p[x + y0*stride] = p[x + y0*stride] xor 0xFFFFFF
    p[x + y1*stride] = p[x + y1*stride] xor 0xFFFFFF
    x += 1

  while y < y1:
    p[x0 + y*stride] = p[x0 + y*stride] xor 0xFFFFFF
    p[x1 + y*stride] = p[x1 + y*stride] xor 0xFFFFFF
    y += 1

  discard updateSurface(window)

# vim: ts=2 sts=2 sw=2 expandtab:
