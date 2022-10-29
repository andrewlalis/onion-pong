module model;

import dvec;
import gamemode;
import bindbc.sdl;
import util.sdl_draw_utils;

const SCREEN_SIZE = 800;

class Player : Renderable {
    public Vec2f position;
    public Vec2f velocity;
    public float baseRadius = 0.03f;
    public float maxSpeed = 0.8f;
    public int layers = 5;
    public PlayerInputState input;

    public float getTotalRadius() {
        return baseRadius + 0.0001f * layers;
    }

    public void render(SDL_Renderer* renderer) {
        SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        SDL_RenderFillCircle(
            renderer,
            cast(int) (position.x * SCREEN_SIZE),
            cast(int) (position.y * SCREEN_SIZE),
            cast(int) (getTotalRadius() * SCREEN_SIZE)
        );
    }
}

struct PlayerInputState {
    bool up, down, left, right;
}

class Ball : Renderable {
    public Vec2f position;
    public Vec2f velocity;
    public float radius = 0.015f;

    public void render(SDL_Renderer* renderer) {
        SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0x00, 0xFF);
        SDL_RenderFillCircle(
            renderer,
            cast(int) (position.x * SCREEN_SIZE),
            cast(int) (position.y * SCREEN_SIZE),
            cast(int) (radius * SCREEN_SIZE)
        );
    }
}