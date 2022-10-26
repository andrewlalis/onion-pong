# Onion-Pong
A simple single-player or multi-player variation of the classic "Pong" game.

In Onion Pong, you, the player, control a point in 2D space, which is wrapped in various layers. You're the onion. You control the onion's position with your mouse, and scroll to rotate the player's orientation. One or more balls will spawn, and it'll bounce off the edges of the space, and your layers. However, each time it bounces off of a layer, it breaks a piece off. Layers will grow back slowly over time, and your objective is to survive as long as possible.

This game is written in D and uses **SDL** for graphics and player input, and my own **dvec** library for any linear algebra to be done.
