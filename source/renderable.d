module renderable;

import bindbc.sdl;

interface Renderable {
    void render(SDL_Surface* surface, SDL_Renderer* renderer);
}