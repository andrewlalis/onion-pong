module util.sdl_draw_utils;

import std.typecons;
import bindbc.sdl;

alias SDL_WindowData = Tuple!(
    SDL_Window*, "window",
    SDL_Surface*, "surface",
    SDL_Renderer*, "renderer",
    SDL_DisplayMode, "displayMode"
);

SDL_WindowData initSDLWindow(const uint screenSize) {
    import std.stdio;
    SDLSupport support = loadSDL();
	if (support != sdlSupport) {
        throw new Exception("Couldn't load SDL");
	}

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        throw new Exception("Couldn't initialize SDL");
	}
	int displayCount = SDL_GetNumVideoDisplays();
	SDL_DisplayMode displayMode;
	uint chosenDisplayModeIdx = 0;
	uint chosenDisplayModeRefreshRate = 0;
	SDL_DisplayMode chosenDisplayMode;
	foreach (displayIdx; 0 .. displayCount) {
		int displayModes = SDL_GetNumDisplayModes(displayIdx);
		foreach (displayModeIdx; 0 .. displayModes) {
			SDL_GetDisplayMode(displayIdx, displayModeIdx, &displayMode);
			if (displayMode.refresh_rate > chosenDisplayModeRefreshRate) {
				chosenDisplayModeIdx = displayModeIdx;
				chosenDisplayModeRefreshRate = displayMode.refresh_rate;
				chosenDisplayMode = displayMode;
				break;
			}
		}
	}

	SDL_Window* window = SDL_CreateWindow(
		"Onion-Pong",
		SDL_WINDOWPOS_CENTERED_DISPLAY(chosenDisplayModeIdx),
		SDL_WINDOWPOS_CENTERED_DISPLAY(chosenDisplayModeIdx),
		screenSize, screenSize,
		SDL_WINDOW_SHOWN | SDL_WINDOW_BORDERLESS
	);
	SDL_SetWindowDisplayMode(window, &chosenDisplayMode);
	SDL_Surface* surface = SDL_GetWindowSurface(window);
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);


	// Initially set the entire screen to black.
	SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0x00, 0x00, 0x00));
	SDL_UpdateWindowSurface(window);

    return tuple!
        ("window", "surface", "renderer", "displayMode")
        (window, surface, renderer, chosenDisplayMode);
}

void freeWindow(SDL_Window* window) {
    SDL_DestroyWindow(window);
    SDL_Quit();
}


void drawCircle(SDL_Renderer* renderer, int cx, int cy, int r) {
    int offsetX = 0;
    int offsetY = r;
    int d = r - 1;
    // TODO: Implement this!
}

