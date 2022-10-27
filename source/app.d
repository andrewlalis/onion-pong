import std.stdio;
import bindbc.sdl;
import std.math;
import std.algorithm : max;
import dvec;
import util.sdl_draw_utils;

import model;

const SCREEN_SIZE = 800;

int main() {
	auto windowData = initSDLWindow(SCREEN_SIZE);
	SDL_Window* window = windowData.window;
	SDL_Surface* surface = windowData.surface;
	SDL_Renderer* renderer = windowData.renderer;

	Player player;
	player.position = Vec2f(0.5f, 0.5f);
	player.velocity = Vec2f(0);

	bool running = true;
	ulong timeStart, timeEnd;
	const float targetFPS = cast(float) windowData.displayMode.refresh_rate;
	const float millisPerFrame = 1000.0f / targetFPS;
	SDL_Event e;
	while (running) {
		timeStart = SDL_GetPerformanceCounter();
		pollEvents(e, running, player);
		updatePlayerPhysics(player);
		SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0x00, 0x00, 0x00));
		renderPlayer(player, surface);
		SDL_UpdateWindowSurface(window);

		timeEnd = SDL_GetPerformanceCounter();
		float elapsedMillis = (timeEnd - timeStart) / cast(float) SDL_GetPerformanceFrequency() * 1000.0f;
		int millisToDelay = max(0, cast(int) floor(millisPerFrame - elapsedMillis));
		SDL_Delay(millisToDelay);
	}

	freeWindow(window);
	return 0;
}

void pollEvents(ref SDL_Event e, ref bool running, ref Player player) {
	while (SDL_PollEvent(&e)) {
		// Check for quitting.
		if (
			(e.type == SDL_QUIT) ||
			(e.type == SDL_KEYDOWN && e.key.keysym.scancode == SDL_Scancode.SDL_SCANCODE_ESCAPE)
		) {
			running = false;
			break;
		} else if (e.type == SDL_KEYDOWN || e.type == SDL_KEYUP) {
			updatePlayerInputState(player, e.key);
		}
	}
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
			player.velocity.set([0, 0]);
		}
	}

	player.position.add(player.velocity);
	const float radius = player.getTotalRadius();
	float x1 = player.position.x - radius;
	float y1 = player.position.y - radius;
	float x2 = player.position.x + radius;
	float y2 = player.position.y + radius;

	if (x1 < 0) {
		player.position.x = radius;
		player.velocity.x = 0;
	}
	if (y1 < 0) {
		player.position.y = radius;
		player.velocity.y = 0;
	}
	if (x2 > 1) {
		player.position.x = 1f - radius;
		player.velocity.x = 0;
	}
	if (y2 > 1) {
		player.position.y = 1f - radius;
		player.velocity.y = 0;
	}
}

void renderPlayer(ref Player player, SDL_Surface* surface) {
	SDL_Rect playerRect;
	playerRect.x = cast(int) ((player.position.x - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.y = cast(int) ((player.position.y - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.w = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	playerRect.h = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	SDL_FillRect(surface, &playerRect, SDL_MapRGB((*surface).format, 0xFF, 0xFF, 0xFF));
}
