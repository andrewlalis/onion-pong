import std.stdio;
import bindbc.sdl;
import std.math;
import std.algorithm : max;
import dvec;
import util.sdl_draw_utils;

import model;

const SCREEN_SIZE = 800;

int main() {
	SDL_Window* window;
	SDL_Surface* surface;
	SDL_Renderer* renderer;
	SDL_DisplayMode displayMode;
	try {
		SDL_WindowData data = initSDLWindow(SCREEN_SIZE);
		window = data.window;
		surface = data.surface;
		renderer = data.renderer;
		displayMode = data.displayMode;
	} catch (Exception e) {
		writeln(e.msg);
		return 1;
	}

	Player player;
	player.position = Vec2f(0.5f, 0.5f);
	player.velocity = Vec2f(0);

	Ball ball;
	ball.position.set(0.1f, 0.1f);
	ball.velocity.set(0.25f, 0.3f);

	bool running = true;
	ulong timeStart, timeEnd;
	const float targetFPS = cast(float) displayMode.refresh_rate;
	const float millisPerFrame = 1000.0f / targetFPS;
	double timeSinceLastPhysicsTick = 0;
	while (running) {
		timeStart = SDL_GetPerformanceCounter();
		pollEvents(running, player);
		updatePlayerPhysics(player, timeSinceLastPhysicsTick);
		updateBallPhysics(ball, timeSinceLastPhysicsTick);
		SDL_FillRect(surface, null, SDL_MapRGB((*surface).format, 0x00, 0x00, 0x00));
		renderPlayer(player, surface);
		renderBall(ball, surface);
		SDL_UpdateWindowSurface(window);

		timeEnd = SDL_GetPerformanceCounter();
		double elapsedMillis = (timeEnd - timeStart) / cast(double) SDL_GetPerformanceFrequency() * 1000.0f;
		int millisToDelay = max(0, cast(int) floor(millisPerFrame - elapsedMillis));
		SDL_Delay(millisToDelay);
		timeSinceLastPhysicsTick = (SDL_GetPerformanceCounter() - timeStart) / cast(double) SDL_GetPerformanceFrequency();
	}

	freeWindow(window);
	return 0;
}

void pollEvents(ref bool running, ref Player player) {
	SDL_Event e;
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

void updatePlayerPhysics(ref Player player, double dt) {
	const float accelerationFactor = 3f;
	const float decelerationFactor = 10f;

	Vec2f deltaV = Vec2f(0);
	if (player.input.up) deltaV.y = deltaV.y - 1;
	if (player.input.down) deltaV.y = deltaV.y + 1;
	if (player.input.left) deltaV.x = deltaV.x - 1;
	if (player.input.right) deltaV.x = deltaV.x + 1;
	if (deltaV.mag2 > 0) {
		player.velocity.add(deltaV.norm().mul(accelerationFactor * dt));
	} else {
		Vec2f dampening = Vec2f(-player.velocity).mul(decelerationFactor * dt);
		player.velocity.add(dampening);
		if (player.velocity.mag() < 0.0001f) {
			player.velocity.set([0, 0]);
		}
	}
	player.position.add(player.velocity * dt);
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

void updateBallPhysics(ref Ball ball, double dt) {
	ball.position.add(ball.velocity * dt);
	const float radius = ball.radius;
	float x1 = ball.position.x - radius;
	float y1 = ball.position.y - radius;
	float x2 = ball.position.x + radius;
	float y2 = ball.position.y + radius;

	if (x1 < 0) {
		ball.position.x = radius - x1;
		ball.velocity.x = -ball.velocity.x;
	}
	if (y1 < 0) {
		ball.position.y = radius - y1;
		ball.velocity.y = -ball.velocity.y;
	}
	if (x2 > 1) {
		ball.position.x = 1 - radius - (x2 - 1);
		ball.velocity.x = -ball.velocity.x;
	}
	if (y2 > 1) {
		ball.position.y = 1 - radius - (y2 - 1);
		ball.velocity.y = -ball.velocity.y;
	}
	ball.velocity.mul(1.001f);
}

void renderPlayer(ref Player player, SDL_Surface* surface) {
	SDL_Rect playerRect;
	playerRect.x = cast(int) ((player.position.x - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.y = cast(int) ((player.position.y - player.getTotalRadius()) * SCREEN_SIZE);
	playerRect.w = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	playerRect.h = cast(int) (player.baseRadius * 2 * SCREEN_SIZE);
	SDL_FillRect(surface, &playerRect, SDL_MapRGB((*surface).format, 0xFF, 0xFF, 0xFF));
}

void renderBall(ref Ball ball, SDL_Surface* surface) {
	SDL_Rect ballRect;
	ballRect.x = cast(int) ((ball.position.x - ball.radius) * SCREEN_SIZE);
	ballRect.y = cast(int) ((ball.position.y - ball.radius) * SCREEN_SIZE);
	ballRect.w = cast(int) (ball.radius * 2 * SCREEN_SIZE);
	ballRect.h = cast(int) (ball.radius * 2 * SCREEN_SIZE);
	SDL_FillRect(surface, &ballRect, SDL_MapRGB((*surface).format, 0xFF, 0xFF, 0x00));
}
