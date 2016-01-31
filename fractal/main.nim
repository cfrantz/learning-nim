import parseopt2
import strutils
import tables
import sdl2
import sdl2/gfx

import fractal
import functions
import colors
import util

proc usage(): int =
  echo """Usage:
  program [-?] [--w=<width>] [--h=<height>] [-f=<fractal>] [-c=<color>]

  Where:
    -?|--help: Print this help message.
    -w|--width=<x>: Set the image width.
    -f|--fractal=<f>: Set the fractal algorithm.
    -c|--color=<c>: Set the color algorithm.
    -p=x0,y0,x1,y1: Set the starting coordinates.
"""
  echo "Known fractal algorithms:"
  for k in fractalFunc.keys():
    echo "    ", k
  echo "\nKnown color algorithms:"
  for k in colorFunc.keys():
    echo "    ", k
  echo ""
  return 0

proc main(): int =
  var
    width = 640
    height = 480
    x0 = -2.0
    y0 = -2.0
    x1 = 2.0
    y1 = 2.0
    # ff is the fractal function, cf is the color function.
    ff = fractalFunc["mandelbrot"]
    cf = colorFunc["naive"]

  for kind, key, value in getopt():
    case kind
    of cmdArgument:
      echo "Unexpected argument:", key
      return 1
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "?":
        return usage()
      of "width", "w":
        width = parseInt(value.string)
      of "height", "h":
        height = parseInt(value.string)
      of "fractal", "f":
        ff = fractalFunc[value.string]
      of "color", "c":
        cf = colorFunc[value.string]
      of "p":
        var s = (value.string).split(',')
        assert(s.len == 4)
        x0 = parseFloat(s[0])
        y0 = parseFloat(s[1])
        x1 = parseFloat(s[2])
        y1 = parseFloat(s[3])
      else:
        echo "Unexpected option:", key
    of cmdEnd:
      assert(false)

  var
    window: WindowPtr
    render: RendererPtr
    fpsman: FpsManager
    frac: FractalRenderer
    running = true
    wantRender = true
    event = sdl2.defaultEvent
    mx0, my0, mx1, my1: int

  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow("Fractal Viewer", 100, 100,
                        width.cint, height.cint, SDL_WINDOW_SHOWN)
  render = createRenderer(window, -1, Renderer_Accelerated or
                                      Renderer_PresentVsync or
                                      Renderer_TargetTexture)
  fpsman.init()

  frac = NewFractalRenderer(width, height, 1024, window)
  frac.setBounds(x0, y0, x1, y1)

  # This syntax is a bit peculiar.  Its basically
  # frac.setFunction(lambda x, y, b: cf(x,y, ff(x,y,b)))
  frac.setFunction do (x,y: float, b: int) -> uint32:
    return cf(x, y, ff(x, y, b))

  block mainloop:
    while running:
      if wantRender:
        frac.render()
        wantRender = false

      while pollEvent(event):
        if event.kind == QuitEvent:
          running = false
          break mainloop
        elif event.kind == MouseButtonDown:
          if bool(event.button.button and BUTTON_LMASK):
            mx0 = event.button.x
            my0 = event.button.y
            mx1 = mx0
            my1 = my0
            drawSquareXor(window, mx0, my0, mx1, my1)
        elif event.kind == MouseButtonUp:
          if bool(event.button.button and BUTTON_LMASK):
            drawSquareXor(window, mx0, my0, mx1, my1)
            mx1 = event.button.x
            my1 = event.button.y
            frac.setBounds(mx0, my0, mx1, my1)
            wantRender = true
        elif event.kind == MouseMotion:
          if bool(event.motion.state and BUTTON_LMASK):
            drawSquareXor(window, mx0, my0, mx1, my1)
            mx1 = event.motion.x
            my1 = event.motion.y
            drawSquareXor(window, mx0, my0, mx1, my1)
      fpsman.delay()
  return 0

quit(main())

# vim: ts=2 sts=2 sw=2 expandtab:
