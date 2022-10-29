module util.sdl_draw_utils;

import std.typecons;
import bindbc.sdl;

alias SDL_WindowData = Tuple!(
    SDL_Window*, "window",
    SDL_Renderer*, "renderer",
    SDL_DisplayMode, "displayMode"
);

SDL_WindowData initSDLWindow(const uint screenSize) {
    import std.stdio;
	import std.conv;
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
	if (SDL_SetWindowDisplayMode(window, &chosenDisplayMode) < 0) {
		throw new Exception("Could not set window display mode.");
	}
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (renderer is null) {
		throw new Exception("Could not create SDL renderer.");
	}


	// Initially set the entire screen to black.
	SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xFF);
	SDL_RenderClear(renderer);
	SDL_RenderPresent(renderer);

    return tuple!
        ("window", "renderer", "displayMode")
        (window, renderer, chosenDisplayMode);
}

void freeWindow(SDL_Window* window) {
    SDL_DestroyWindow(window);
    SDL_Quit();
}


void SDL_RenderFillCircle(SDL_Renderer* renderer, int x, int y, int r) {
	int offsetX = 0;
	int offsetY = r;
	int d = r - 1;
	int status;
	while (offsetY >= offsetX) {
		status += SDL_RenderDrawLine(renderer, x - offsetY, y + offsetX, x + offsetY, y + offsetX);
		status += SDL_RenderDrawLine(renderer, x - offsetX, y + offsetY, x + offsetX, y + offsetY);
		status += SDL_RenderDrawLine(renderer, x - offsetX, y - offsetY, x + offsetX, y - offsetY);
		status += SDL_RenderDrawLine(renderer, x - offsetY, y - offsetX, x + offsetY, y - offsetX);

		if (status < 0) {
			import std.stdio;
			import std.conv;
			stderr.writefln!"SDL rendering error: %s"(SDL_GetError().to!string);
			SDL_ClearError();
			break;
		}

		if (d >= 2 * offsetX) {
			d -= 2 * offsetX + 1;
			offsetX += 1;
		} else if (d < 2 * (r - offsetY)) {
			d += 2 * offsetY - 1;
			offsetY -= 1;
		} else {
			d += 2 * (offsetY - offsetX - 1);
			offsetY -= 1;
			offsetX += 1;
		}
	}
}

