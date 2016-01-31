# Fractal Renderer

## Example output

![Mandelbrot](images/mandelbrot.png)
![BurningShip](images/burningship.png)

* `./main -c:roygbiv -w:256 -h:256 -p:0.3291233577328967,-0.05800491402624175,0.3297866649882053,-0.0573523121420294`

* `./main -w:256 -h:256 -f:burningship -c:onthesea -p=-1.817511,-0.117813,-1.701644,0.034875`

## Requirements

1.  SDL2 libraries
	```
	sudo apt-get install libsdl2-2.0 \
		libsdl2-gfx-1.0-0 \
		libsdl2-image-2.0-0 \
		libsdl2-mixer-2.0-0 \
		libsdl2-net-2.0-0 \
		libsdl2-ttf-2.0-0 \
		libsdl2-dev
	```

2.  nim sdl2 module
	```
	nimble install sdl2
	```
