import sdl2
import sdl2.gfx
import strutils
import threadpool
import times
import util

type
  FractalRenderer* = ref object of RootObj
    width, height: int
    bailout: int
    x0, y0, x1, y1: float
    fracfunc: proc(x, y: float, bailout: int): uint32
    window: sdl2.WindowPtr
    updateDuringRender: bool


proc NewFractalRenderer*(width, height, bailout: int,
                         window: sdl2.WindowPtr,
                         updateDuringRender: bool): FractalRenderer =
  result = FractalRenderer(width: width, height: height,
                           bailout: bailout, window: window,
                           updateDuringRender: updateDuringRender,
                           x0: -2.0, y0: -2.0, x1: 2.0, y1: 2.0)


proc setBounds*(this: FractalRenderer, x0, y0, x1, y1: float): void =
  this.x0 = x0
  this.y0 = y0
  this.x1 = x1
  this.y1 = y1


proc setBounds*(this: FractalRenderer, px0, py0, px1, py1: int): void =
  let
    dx = this.x1 - this.x0
    dy = this.y1 - this.y0
  var
    x0 = px0
    y0 = py0
    x1 = px1
    y1 = py1

  maybeSwap(x0, x1)
  maybeSwap(y0, y1)

  this.x1 = this.x0 + dx * (x1 / this.width)
  this.y1 = this.y0 + dy * (y1 / this.height)
  this.x0 = this.x0 + dx * (x0 / this.width)
  this.y0 = this.y0 + dy * (y0 / this.height)


proc setFunction*(this: FractalRenderer, 
                  f: proc(x, y: float, bailout: int): uint32): void =
  this.fracfunc = f


proc render*(this: FractalRenderer): void =
  let
    xi = (this.x1 - this.x0) / this.width.float
    yi = (this.y1 - this.y0) / this.height.float
  var
    xx = this.x0
    yy = this.y0
    p = 0
    surface = getSurface(this.window)
    pptr = getPixelPointer(surface)
    stride = surface.pitch div 4
    t0, t1: float

  echo "Coordinates: ", this.x0, ",", this.y0, ",", this.x1, ",", this.y1
  t0 = epochTime()
  for y in 0..this.height-1:
    xx = this.x0
    for x in 0..this.width-1:
      pptr[p] = this.fracfunc(xx, yy, this.bailout)
      xx += xi
      p += 1
    yy += yi
    p += stride - this.width
    if this.updateDuringRender:
      discard updateSurface(this.window)
  t1 = epochTime()
  echo "Rendered ", p, " pixels"
  echo "Finished in ", (t1-t0), "s"
  discard updateSurface(this.window)

proc renderLine(this: FractalRenderer, yy, xi: float,
                pptr: ptr uint32, offset: int): void =
  var
    xx = this.x0
    p = offset

  for x in 0..this.width-1:
    pptr[p] = this.fracfunc(xx, yy, this. bailout)
    xx += xi
    p += 1
  if this.updateDuringRender:
    discard updateSurface(this.window)

{.experimental.}
proc parallelRender*(this: FractalRenderer): void =
  let
    xi = (this.x1 - this.x0) / this.width.float
    yi = (this.y1 - this.y0) / this.height.float
  var
    yy = this.y0
    p = 0
    surface = getSurface(this.window)
    pptr = getPixelPointer(surface)
    stride = surface.pitch div 4
    t0, t1: float

  echo "Coordinates: ", this.x0, ",", this.y0, ",", this.x1, ",", this.y1
  t0 = epochTime()

  # Spawn work into the threadpool.
  parallel:
    for y in 0..this.height-1:
      spawn this.renderLine(yy, xi, pptr, p)
      yy += yi
      p += stride
  t1 = epochTime()
  echo "Finished in ", (t1-t0), "s"
  discard updateSurface(this.window)





# vim: ts=2 sts=2 sw=2 expandtab:
