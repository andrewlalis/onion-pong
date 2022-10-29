import std.stdio;
import bindbc.sdl;
import std.math;
import std.algorithm : max;
import dvec;
import util.sdl_draw_utils;

import model;
import gamemode;
import gamemodes;

const SCREEN_SIZE = 800;

int main() {
	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_DisplayMode displayMode;
	try {
		SDL_WindowData data = initSDLWindow(SCREEN_SIZE);
		window = data.window;
		renderer = data.renderer;
		displayMode = data.displayMode;
	} catch (Exception e) {
		import std.conv;
		stderr.writeln(e.msg);
		stderr.writefln!"SDL Error: %s"(SDL_GetError().to!string);
		return 1;
	}

	Gamemode gamemode = new SingleplayerOnionPongMode();

	bool running = true;
	ulong timeStart, timeEnd;
	const float targetFPS = cast(float) displayMode.refresh_rate;
	writefln!"Target FPS: %.1f"(targetFPS);
	const float millisPerFrame = 1000.0f / targetFPS;
	double timeSinceLastPhysicsTick = 0;
	while (running) {
		timeStart = SDL_GetPerformanceCounter();

		gamemode.tick(timeSinceLastPhysicsTick);
		if (gamemode.isGameOver()) {
			running = false;
			break;
		}
		gamemode.render(renderer);

		timeEnd = SDL_GetPerformanceCounter();
		double elapsedMillis = (timeEnd - timeStart) / cast(double) SDL_GetPerformanceFrequency() * 1000.0f;
		int millisToDelay = max(0, cast(int) floor(millisPerFrame - elapsedMillis));
		SDL_Delay(millisToDelay);
		timeSinceLastPhysicsTick = (SDL_GetPerformanceCounter() - timeStart) / cast(double) SDL_GetPerformanceFrequency();
	}

	freeWindow(window);
	return 0;
}
