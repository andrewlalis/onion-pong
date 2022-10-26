import std.stdio;
import bindbc.sdl;
import std.math;
import std.algorithm : max;
import dvec;

import model;

const SCREEN_SIZE = 800;

int main() {
	SDLSupport support = loadSDL();
	if (support != sdlSupport) {
		writeln("Couldn't load SDL.");
		return 1;
	}

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		writeln("Couldn't initialize SDL.");
		return 1;
	}

	SDL_Window* window = SDL_CreateWindow("Onion-Pong", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_SIZE, SCREEN_SIZE, SDL_WINDOW_SHOWN);
	SDL_Surface* surface = SDL_GetWindowSurface(window);
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	writeln("Initialized rendering system");

	// Initially set the entire screen to black.
	SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0x00, 0x00, 0x00));
	SDL_UpdateWindowSurface(window);


	Player player;
	player.position = Vec2f(0.5f, 0.5f);
	player.velocity = Vec2f(0);

	bool running = true;
	ulong timeStart, timeEnd;
	SDL_Event e;
	while (running) {
		timeStart = SDL_GetPerformanceCounter();
		// Check events
		while (SDL_PollEvent(&e)) {
			if (
				e.type == SDL_QUIT ||
				e.type == SDL_KEYDOWN && e.key.keysym.scancode == SDL_Scancode.SDL_SCANCODE_ESCAPE
			) {
				running = false;
				break;
			} else if (e.type == SDL_KEYDOWN || e.type == SDL_KEYUP) {
				updatePlayerInputState(player, e.key);
			}
		}

		// physics
		updatePlayerPhysics(player);
		
		// render
		SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0x00, 0x00, 0x00));
		renderPlayer(player, surface);
		SDL_UpdateWindowSurface(window);



		timeEnd = SDL_GetPerformanceCounter();
		float elapsedMillis = (timeEnd - timeStart) / cast(float) SDL_GetPerformanceFrequency() * 1000.0f;
		int millisToDelay = max(0, cast(int) floor(16.666f - elapsedMillis));
		SDL_Delay(millisToDelay);
	}
	writeln("done");

	SDL_DestroyWindow(window);
	SDL_Quit();
	return 0;
}

void updatePlayerInputState(ref Player player, SDL_KeyboardEvent ke) {
	bool active = ke.type == SDL_KEYDOWN;
	if (ke.keysym.scancode == SDL_Scancode.SDL_SCANCODE_W) {
		player.input.up = active;
	} else if (ke.keysym.scancode == SDL_Scancode.SDL_SCANCODE_S) {
		player.input.down = active;
	} else if (ke.keysym.scancode == SDL_Scancode.SDL_SCANCODE_A) {
		player.input.left = active;
	} else if (ke.keysym.scancode == SDL_Scancode.SDL_SCANCODE_D) {
		player.input.right = active;
	}
}

void updatePlayerPhysics(ref Player player) {
	Vec2f deltaV = Vec2f(0);
	if (player.input.up) deltaV[1] = deltaV[1] - 1;
	if (player.input.down) deltaV[1] = deltaV[1] + 1;
	if (player.input.left) deltaV[0] = deltaV[0] - 1;
	if (player.input.right) deltaV[0] = deltaV[0] + 1;
	if (deltaV.mag2 > 0) {
		player.velocity.add(deltaV.norm().mul(0.0005f));
	} else {
		Vec2f dampening = Vec2f(-player.velocity).mul(0.05);
		player.velocity.add(dampening);
		if (player.velocity.mag() < 0.0001f) {
			player.velocity.data = [0f, 0f];
		}
	}

	player.position.add(player.velocity);
	const float radius = player.getTotalRadius();
	float x1 = player.position[0] - radius;
	float y1 = player.position[1] - radius;
	float x2 = player.position[0] + radius;
	float y2 = player.position[1] + radius;

	if (x1 < 0) {
		player.position[0] = radius;
		player.velocity[0] = 0;
	}
	if (y1 < 0) {
		player.position[1] = radius;
		player.velocity[1] = 0;
	}
	if (x2 > 1) {
		player.position[0] = 1f - radius;
		player.velocity[0] = 0;
	}
	if (y2 > 1) {
		player.position[1] = 1f - radius;
		player.velocity[1] = 0;
	}
}

void renderPlayer(ref Player player, SDL_Surface* surface) {
	SDL_Rect playerRect;
	playerRect.x = cast(int) ((player.position[0] - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.y = cast(int) ((player.position[1] - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.w = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	playerRect.h = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	SDL_FillRect(surface, &playerRect, SDL_MapRGB((*surface).format, 0xFF, 0xFF, 0xFF));
}
