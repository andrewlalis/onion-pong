module gamemodes;

import bindbc.sdl;
import dvec;
import gamemode;
import model;
import std.stdio;

class SingleplayerOnionPongMode : Gamemode {
    private Player player;
    private Ball ball;
    private bool running;

    this() {
        player = new Player();
        player.position = Vec2f(0.5f);
        player.velocity = Vec2f(0);
        ball = new Ball();
        ball.position = Vec2f(0.1f);
        ball.velocity = Vec2f(0.1f, 0.05f);
        running = true;
    }

    void tick(double dt) {
        pollEvents();
        updatePlayerPhysics(dt);
        updateBallPhysics(dt);
        computeCollision();
    }

    void render(SDL_Renderer* renderer) {
        SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xFF);
		SDL_RenderClear(renderer);
		player.render(renderer);
        ball.render(renderer);
		SDL_RenderPresent(renderer);
    }

    bool isGameOver() {
        return !running;
    }

    void pollEvents() {
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
                updatePlayerInputState(e.key);
            }
        }
    }

    void updatePlayerInputState(SDL_KeyboardEvent ke) {
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

    void updatePlayerPhysics(double dt) {
        const float accelerationFactor = 2f;
        const float decelerationFactor = 10f;

        Vec2f deltaV = Vec2f(0);
        if (player.input.up) deltaV.add(Vec2f(0, -1));
        if (player.input.down) deltaV.add(Vec2f(0, 1));
        if (player.input.left) deltaV.add(Vec2f(-1, 0));
        if (player.input.right) deltaV.add(Vec2f(1, 0));
        if (deltaV.mag2 > 0) {
            player.velocity.add(deltaV.norm().mul(accelerationFactor * dt));
            if (player.velocity.mag2() > player.maxSpeed * player.maxSpeed) {
                player.velocity.norm().mul(player.maxSpeed);
            }
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
            player.velocity.x = -player.velocity.x * 0.8f;
        }
        if (y1 < 0) {
            player.position.y = radius;
            player.velocity.y = -player.velocity.y * 0.8f;
        }
        if (x2 > 1) {
            player.position.x = 1f - radius;
            player.velocity.x = -player.velocity.x * 0.8f;
        }
        if (y2 > 1) {
            player.position.y = 1f - radius;
            player.velocity.y = -player.velocity.y * 0.8f;
        }
    }

    void updateBallPhysics(double dt) {
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
    }

    void computeCollision() {
        const float dist2 = (ball.position - player.position).mag2();
        const float threshold2 = (ball.radius + player.getTotalRadius()) * (ball.radius + player.getTotalRadius());
        if (dist2 < threshold2) {
            const float ballMass = 1;
            const float playerMass = 10;

            float cb1 = (ballMass - playerMass) / (ballMass + playerMass);
            float cb2 = (2 * playerMass) / (ballMass + playerMass);
            float cp1 = (2 * ballMass) / (ballMass + playerMass);
            float cp2 = (playerMass - ballMass) / (ballMass + playerMass);
            float inelasticFactor = 0.9f;

            ball.velocity = cb1 * ball.velocity + cb2 * player.velocity * inelasticFactor;
            player.velocity = cp1 * ball.velocity + cp2 * player.velocity * inelasticFactor;

            // Move the ball out of collision with the player so that we don't collide on the next tick by accident.
            Vec2f playerToBall = (ball.position - player.position);
            const float threshold = ball.radius + player.getTotalRadius();
            const float penetration = threshold - playerToBall.mag();
            ball.position.add(playerToBall.norm().mul(penetration));
        }
    }
}