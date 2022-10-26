import std.stdio;
import bindbc.sdl;

void main() {
	SDLSupport support = loadSDL();
	if (support != sdlSupport) {
		writeln("Couldn't load SDL.");
		return;
	}

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		writeln("Couldn't initialize SDL.");
		return;
	}

	SDL_Window* window = SDL_CreateWindow("Onion-Pong", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 800, SDL_WINDOW_SHOWN);
	SDL_Surface* surface = SDL_GetWindowSurface(window);
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

	SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0xFF, 0x00, 0xFF));
	SDL_UpdateWindowSurface(window);

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e)) {
			if (e.type == SDL_QUIT) {
				quit = true;
				break;
			} else if (e.type == SDL_MOUSEMOTION) {
				writefln!"Mouse: %d, %d"(e.motion.x, e.motion.y);
			} else if (e.type == SDL_MOUSEWHEEL) {
				writefln!"%s"(e.wheel);
			}
		}
	}

	SDL_DestroyWindow(window);
	SDL_Quit();
}
