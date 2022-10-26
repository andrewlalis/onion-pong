module model;

import dvec;

struct Player {
    Vec2f position;
    Vec2f velocity;
    float baseRadius = 40;
    int layers;
    PlayerInputState input;
}

struct PlayerInputState {
    bool up, down, left, right;
}