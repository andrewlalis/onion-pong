module gamemode;

import bindbc.sdl;

interface Renderable {
    void render(SDL_Renderer* renderer);
}

interface Gamemode : Renderable {
    void tick(double dt);
    bool isGameOver();
}