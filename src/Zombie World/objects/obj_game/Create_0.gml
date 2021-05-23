#region Tile structure.

// Tile types.
enum TILE{ FOREST, CITY, WATER}

function __tile(_type) constructor{
	// Tile struct.
	
	// Set type function.
	set_type = function(_type){ // Function that sets type.
		// @function set_type(_type)
		// @description Function that sets type.
		// @param {TILE} _type Type to set.
		
		// Setting.
		__type = _type;
		
		// Updating color.
		__update_color();
	}

	// Get type function.
	get_type = function(){ // Function that gets type.
		// @function get_type()
		// @description Function that gets type.
		// @returns {TILE} Type.
		
		// Returning.
		return __type;
	}
	
	// Update color function.
	__update_color = function(){
		// @function __update_color()
		// @description Function that updates color.
		
		// Default color.
		var _color = array_get(COLOR, __type);
		
		// Changing color a bit.
		_color = make_color_hsv(color_get_hue(_color), color_get_saturation(_color), color_get_value(_color) + irandom_range(-6, 6));
		
		// Setting color.
		color = _color;
	}
	
	// Setting type from constructor.
	__type = _type;
	
	// Calling update color.
	__update_color();
}
	
#endregion

#region Vector structure.

function __vector2d(_x, _y) constructor{
	// Vector 2D structure.
	
	// Changing x, y.
	x = _x;
	y = _y;
}

#endregion

#region Constants.

// Size of one tile.
#macro __TILE_SIZE 32

// World size.
#macro __WORLD_SIZE ((room_width + room_height) / 2 / __TILE_SIZE) * 4

// Divisor of the light update speed.
#macro LIGHT_SPEED_DIVISOR 4

// Size of the one chunk for generation.
#macro __GENERATOR_CHUNK_SIZE 32

// How much worms on one chunk.
#macro __GENERATOR_CHUNK_WORMS 4

// Tile colors.
#macro COLOR [c_green, c_dkgray, make_color_rgb(63, 60, 183)]

// Max value for light.
#macro LIGHT_MAX 50

// How much tiles draw on chunk (screen).
#macro CHUNK_SIZE room_width / __TILE_SIZE

// Light enabled or not.
#macro LIGHT_ENABLED false

// Should we only update light emmiters when we need it or all time? (Idle optimization.
#macro LIGHT_ENABLED_EMMITERS_UPDATE_OPTIMIZATION true

// How much frames to skip on launch.
#macro LAUNCH_FRAME_SKIP 0;

// Circle filtering (WIP).
#macro CIRCLE_FILTER 5
			
// Fullscreen or not.
#macro FULLSCREEN false

#endregion

#region Variables.

// How much time now.
global.__game_world_light_value = 25;

// Time direction.
global.__game_world_light_direction = -1;

// Creating light surface.
global.__game_world_light_surface = undefined;

// Array of points where to create lights at the end of the frame.
global.__game_world_light_frame_emmiters = [];

// Position of the chunk.
global.__game_chunk_position = new __vector2d(0, 0);

// Should we update light emmiters now or not.
global.__game_world_update_light_emmiters = true;

// Should we skip first frame.
global.__game_frame_skip = LAUNCH_FRAME_SKIP;

#endregion

#region Functions

function __game_generate_world(){ // Function that generates world.
	// @functon __game_generate_world()
	// @description Function that generates world.
	
	// Randomizing.
	randomize();
	
	// Clearing game world.
	global.__game_world = [];
	
	// Filling.
	for (var _x = 0; _x < __WORLD_SIZE; _x++)
		for (var _y = 0; _y < __WORLD_SIZE; _y++){
			// Iteraing over all __WORLD_SIZE.
			
			// Setting tile as forest.
			global.__game_world[_x][_y] = new __tile(TILE.FOREST);
		};
		
	// Worms.
	for(var _chunk_x = 0; _chunk_x <= __WORLD_SIZE; _chunk_x += __GENERATOR_CHUNK_SIZE){
		for(var _chunk_y = 0; _chunk_y <= __WORLD_SIZE; _chunk_y += __GENERATOR_CHUNK_SIZE){
			// Iterating over chunk.
			
			// Generating worms (Cities, water)
			repeat(__GENERATOR_CHUNK_WORMS){ 
				__game_generator_generate_worm(TILE.WATER, irandom_range(3, 10), irandom_range(_chunk_x, _chunk_x + __GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + __GENERATOR_CHUNK_SIZE), false); 
				__game_generator_generate_worm(TILE.CITY, irandom_range(10, 15), irandom_range(_chunk_x, _chunk_x + __GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + __GENERATOR_CHUNK_SIZE), true); 
			}
		}}

}

function __game_generator_generate_worm(_fill, _size, _x, _y, _nooverflow){ // Function that generates random worm with given tile size and pos.
	// @function __game_generator_generate_worm(_fill, _size, _x, _y, _nooverflow)
	// @description Function that generates random worm with given tile size and pos.
	
	for (var _repeat = 0; _repeat < _size; _repeat++){
		// Loop for size.
		
		// Not set if not on world pos.
		if _x < 0 or _y < 0 or _x >= __WORLD_SIZE or _y >= __WORLD_SIZE{ continue; };
		
		// Filling world tile.
		if not _nooverflow or global.__game_world[_x][_y].get_type() != _fill{ global.__game_world[_x][_y].set_type(_fill);}
		
		// Moving.
		_x += irandom_range(-1, 1);
		_y += irandom_range(-1, 1);
		
		// Increasing size if not moved.
		if _x == 0 and _y == 0 _size++;
	}
}

function __game_update_time(){ // Function that updates time.
	// @function __game_update_time()
	// @description Function that updates time.
	
	// Updating light value by direction.
	global.__game_world_light_value += global.__game_world_light_direction / LIGHT_SPEED_DIVISOR;
	
	// Changing direction if reached max value.
	if global.__game_world_light_value == LIGHT_MAX or global.__game_world_light_value == -LIGHT_MAX{
		global.__game_world_light_direction = -global.__game_world_light_direction;
	}
	
	var _xspeed = (keyboard_check(vk_right) - keyboard_check(vk_left));
	var _yspeed = (keyboard_check(vk_down) - keyboard_check(vk_up));
	global.__game_chunk_position.x = clamp(global.__game_chunk_position.x + _xspeed, 0, __WORLD_SIZE - CHUNK_SIZE);
	global.__game_chunk_position.y = clamp(global.__game_chunk_position.y + _yspeed, 0, __WORLD_SIZE - CHUNK_SIZE);
	if _xspeed != 0 or _yspeed != 0{
		global.__game_world_update_light_emmiters = true;
	}
}

function __game_draw_world(){ // Function that draws world.
	// @functon __game_draw_world()
	// @description Function that draws world.

	// First frame skip.
	if global.__game_frame_skip != 0 return --global.__game_frame_skip;

	// Clearing all frame light emmiters if updating light.
	if global.__game_world_update_light_emmiters { __game_light_clear_frame_emmiters(); }
	
	// Player positions.
	var _player_x = global.__game_chunk_position.x + floor(CHUNK_SIZE / 2);
	var _player_y = global.__game_chunk_position.y + floor(CHUNK_SIZE / 2);
	
	for (var _x = global.__game_chunk_position.x; _x <  global.__game_chunk_position.x + CHUNK_SIZE; _x++)
		for (var _y = global.__game_chunk_position.y; _y < global.__game_chunk_position.y + CHUNK_SIZE; _y++){
			// Iteraing over all __WORLD_SIZE.
			
			// Tile player or not.
			var _player = _x == _player_x and _y = _player_y;
			
			// Getting time.
			var _tile = global.__game_world[_x][_y];
			
			// Setting color for tile.
			draw_set_color(_tile.color);
			
			// Getting tile position.
			var _tile_x = (_x - global.__game_chunk_position.x) * __TILE_SIZE;
			var _tile_y = (_y - global.__game_chunk_position.y) * __TILE_SIZE;
			
			// Adding to frame emmiters if city.
			if LIGHT_ENABLED and (not LIGHT_ENABLED_EMMITERS_UPDATE_OPTIMIZATION or global.__game_world_update_light_emmiters) and (_tile.get_type() == TILE.CITY or _player) __game_light_add_frame_emmiter(_tile_x, _tile_y);
			
			// Drawing rectangle.
			draw_rectangle(_tile_x, _tile_y,  _tile_x + __TILE_SIZE, _tile_y + __TILE_SIZE,  false);
			
			// Drawing player.
			if _player{ draw_set_color(c_red) draw_circle(_tile_x, _tile_y, 5, false)};
			
			// Circle filtering.
			if CIRCLE_FILTER draw_circle(_tile_x, _tile_y, (__TILE_SIZE / 16) * CIRCLE_FILTER, false);
		}
	
	// Drawing final light.
	if LIGHT_ENABLED __game_draw_light();
}

function __game_draw_light(){ // Function that draws light.
	// @function __game_draw_light()
	// @description Function that draws light.
	
	// Recreating surface if deleted.
	if is_undefined(global.__game_world_light_surface) or not surface_exists(global.__game_world_light_surface)
		global.__game_world_light_surface = surface_create(room_width, room_height);
	
	// Setting light surface to draw.
	surface_set_target(global.__game_world_light_surface);
	
	// Clearing surface.
	gpu_set_blendmode(bm_subtract);
	draw_rectangle(0, 0, room_width, room_height, false);
	gpu_set_blendmode(bm_normal);
	
	// Drawing black rectangle based on current light value.
	draw_set_alpha(abs(global.__game_world_light_value) / LIGHT_MAX); draw_set_color(c_black);
	draw_rectangle(0, 0, room_width, room_height, false);
	
	// Setting GPU blendmode to subtract.
	gpu_set_blendmode(bm_subtract);
	
	// Getting emmiters count.
	var _emmiters_count = array_length(global.__game_world_light_frame_emmiters);
	
	// Setting alpha for light.
	draw_set_alpha(0.5);
			
	for(var _emmiter_index = 0; _emmiter_index < _emmiters_count; _emmiter_index++){
		// Iterating over all emmiters.
		
		// Getting emmiter position.
		var _emmiter_postion = global.__game_world_light_frame_emmiters[_emmiter_index];
		
		// Drawing circle of light.
		draw_circle(_emmiter_postion.x, _emmiter_postion.y, 5 * __TILE_SIZE, false);
	}
	
	// Setting draw setup back.
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	
	// Setting back defafult surface target.
	surface_reset_target();
	
	// Drawing surface of light.
	draw_surface(global.__game_world_light_surface, 0, 0);
	
	// Disabling world light emmiters update if optimization is enabling.
	if LIGHT_ENABLED_EMMITERS_UPDATE_OPTIMIZATION global.__game_world_update_light_emmiters = false;
}

function __game_light_add_frame_emmiter(_x, _y){ // Function that adds new light frame emmiter.
	// @function __game_light_add_frame_emmiter(_x, _y)
	// @description Function that adds new light frame emmiter.
	
	// Adding.
	array_push(global.__game_world_light_frame_emmiters, new __vector2d(_x, _y));
}

function __game_light_clear_frame_emmiters(){ // Function that clears all light frame emmiter.
	// @function __game_light_clear_frame_emmiters()
	// @description Function that clears all light frame emmiter.
	
	// Clearing.
	global.__game_world_light_frame_emmiters = [];
}
	
#endregion

// Generating world.
__game_generate_world();

// Enabling overlay.
show_debug_overlay(true);

//gc_enable(false);

// Fullscreen.
window_set_fullscreen(FULLSCREEN);