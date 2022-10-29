module gamemode;

import renderable;

interface Gamemode {
    void tick(double dt);
    Renderable[] getRenderables();
}