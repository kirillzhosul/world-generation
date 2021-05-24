/// @description Settings for the world.
/// @author Kirill Zhosul (@kirillzhosul)

// Screen size.
#macro SCREEN_SIZE 1
#macro SCREEN_WIDTH floor(room_width / SCREEN_SIZE)
#macro SCREEN_HEIGHT floor(room_height / SCREEN_SIZE)

// Maximal value for the lightess in the world.
#macro WORLD_LIGHTHNESS_MAXIMAL 50

// Size in pixels of the one cell.
#macro WORLD_TILE_SIZE 32

// Multiplayer of the world to screen.
#macro WORLD_SIZE 4

// World with and height.
#macro WORLD_WIDTH floor(SCREEN_WIDTH / WORLD_TILE_SIZE) * WORLD_SIZE
#macro WORLD_HEIGHT floor(SCREEN_HEIGHT / WORLD_TILE_SIZE) * WORLD_SIZE

// Multiplayer of the world to chunk.
#macro WORLD_CHUNK_SIZE 1

// How much to mix colors when mixing (1 is full mix).
#macro WORLD_COLOR_MIXING_VALUE 8

// Should we mix colors on generation (Should be improved later).
#macro WORLD_COLOR_MIX true

// Chunk sizes.
#macro CHUNK_WIDTH floor(SCREEN_WIDTH / WORLD_TILE_SIZE) * WORLD_CHUNK_SIZE
#macro CHUNK_HEIGHT floor(SCREEN_HEIGHT / WORLD_TILE_SIZE) * WORLD_CHUNK_SIZE

// Should we use only default colors? (Reduce memory and increase cpu usage a bit)(Makes world looks bad) (WARNING THERE IS MEMORY LEAK IF THIS IS ENABLED.
#macro WORLD_TILE_COLOR_OPTIMIZATION false

// Should we force redraw tiles all time or not? (DO NOT ENABLE, VERY HEAVY!)
#macro WORLD_FORCE_REDRAW_TILES false

// Color of the tiles (default)(changes if WORLD_TILE_COLOR_OPTIMIZATION disabled).
#macro WORLD_TILE_COLORS [c_green, c_dkgray, make_color_rgb(63, 60, 183), make_color_rgb(211, 158, 50)]

// FUN World tile filter circle (Draws circle over the tile so all world have like HEX view)(Means radius of the circle).
#macro WORLD_TILE_FILTER_CIRCLE 0 // 5 * (floor(WORLD_TILE_SIZE / 16))

// Is world lighting enabled or not.
#macro WORLD_LIGHT_ENABLED true

// Should process cities?.
#macro WORLD_CITIES_ENABLED true

// Names for the cities.
#macro WORLD_CITIES_NAMES ["City"]

// Should we redraw light every frame? (May leave enabled, will break dynamic light).
#macro WORLD_FORCE_REDRAW_LIGHT true

// Size of the light sources.
#macro WORLD_LIGHT_SIZE 5

// Opacity of the light sources.
#macro WORLD_LIGHT_OPACITY 0.05

// Should we draw tiles or not.
#macro WORLD_TILES_ENABLED true

// Should we draw mouse flashlight or not. (Means radius of the circle).
#macro WORLD_DRAW_MOUSE_FLASHLIGHT 0 // 100

// Should we draw white selection around cities when hovering.
#macro WORLD_DRAW_CITIES_SELECTION true

// Should we update time?
#macro WORLD_UPDATE_TIME true

// Should we allo movement?
#macro WORLD_ALLOW_MOVEMENT true

// Should we allow placement?
#macro WORLD_ALLOW_PLACEMENT true

// Placement tile index.
#macro WORLD_PLACEMENT_TILE __TILE.WATER

// Default tile for the generator.
#macro WORLD_GENERATOR_DEFAULT_TILE __TILE.FOREST

// Size of the one chunk for generation.
#macro WORLD_GENERATOR_CHUNK_SIZE 32

// How much worms on one chunk.
#macro WORLD_GENERATOR_CHUNK_WORMS 4

// Size of the placement.
#macro WORLD_PLACEMENT_SIZE 3
