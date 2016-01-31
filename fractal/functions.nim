import complex
import tables

proc mandelbrot(x, y: float, bailout: int): float {.procvar.} =
  var
    c: Complex = (re: x, im: y)
    z: Complex = (re: 0.0, im: 0.0)
    i = 0
  while i < bailout:
    # This should be abs(z), but computing the absolute value of a complex
    # number is slow (because it's sqrt of the sum of the squares).  A quick
    # optimization is to square the components and compare agains the square
    # of the mangnitude
    if z.re*z.re + z.im*z.im > 4.0:
      break
    z = z*z + c
    i += 1
  return i / bailout

proc burningship(x, y: float, bailout: int): float =
  var
    c: Complex = (re: x, im: y)
    z: Complex = (re: 0.0, im: 0.0)
    i = 0
  while i < bailout:
    # This should be abs(z), but computing the absolute value of a complex
    # number is slow (because it's sqrt of the sum of the squares).  A quick
    # optimization is to square the components and compare agains the square
    # of the mangnitude
    if z.re*z.re + z.im*z.im > 4.0:
      break
    # The burning ship was discovered by an accidental mistake in implementing
    # a mandelbrot function
    z.re = abs(z.re)
    z.im = abs(z.im)
    z = z*z + c
    i += 1
  return i / bailout

proc newton1(x, y: float, bailout: int): float =
  var
    z: Complex = (re: x, im: y)
    z1, dz: Complex
    i = 0
  while i < bailout:
    z1 = z*z*z - 1.0
    if abs(z1) < 0.000000001:
      break
    dz = 3.0 * z*z
    z = z - (z1/dz)
    i += 1
  return i / bailout


var
  fractalFunc* = initTable[string, proc(x, y: float, bailout: int): float]()

fractalFunc["mandelbrot"] = mandelbrot
fractalFunc["burningship"] = burningship
fractalFunc["newton1"] = newton1

# vim: ts=2 sts=2 sw=2 expandtab:
