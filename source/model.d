module model;

import dvec;

struct Player {
    Vec2f position;
    Vec2f velocity;
    float baseRadius = 0.02f;
    int layers = 5;
    PlayerInputState input;

    float getTotalRadius() {
        return baseRadius + 0.0001f * layers;
    }
}

struct PlayerInputState {
    bool up, down, left, right;
}