/// @description Initialising world.
/// @author Kirill Zhosul (@kirillzhosul)

#region Variables.

// How much light in the world now.
__world_lightness = WORLD_LIGHTHNESS_MAXIMAL;

// Position of the world chunk to draw.
__world_chunk_x = 0;
__world_chunk_y = 0;

// Surfaces (Tile surface and light surface).
__world_surface_tiles = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);
__world_surface_light = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);

// All light sources as array.
__world_light_sources = [];

// By how __world_lightness change when updating time (DO NOT CHANGE, changes by code).
__world_lightness_change = -1;

// If true, will redraw tiles surface, used as flag to redraw when changed.
__world_force_redraw_tiles = true;

// If true, will redraw light surface, used as flag to redraw when changed.
__world_force_redraw_light = true;

// World cities data.
__world_cities = [];

// Array of the world.
__world = [];

#endregion

#region Tile struct.

// Tile types.
enum __TILE{ FOREST, CITY, WATER, DESERT }

function __tile(_type) constructor{
	// Tile struct.
	
	// Set type function.
	self.set_type = function(_type){ // Function that sets type.
		// @function set_type(_type)
		// @description Function that sets type.
		// @param {TILE} _type Type to set.
		
		// Setting.
		self.type = _type;
		
		// Updating color.
		self.__update_color();
	}

	// Get type function.
	self.get_type = function(){ // Function that gets type.
		// @function get_type()
		// @description Function that gets type.
		// @returns {TILE} Type.
		
		// Returning.
		return self.type;
	}
	
	// Get color function.
	self.get_color = function(){ // Function that gets color.
		// @function get_color()
		// @description Function that gets color.
		// @returns {COLOR} Color.
		
		// Color optimization.
		if WORLD_TILE_COLOR_OPTIMIZATION{ return array_get(WORLD_TILE_COLORS, self.type); }
		
		// Returning.
		return self.color;
	}
		self.draw = function(_x, _y){ // Function that draws tile.
		// @function draw(_x, _y)
		// @description Function that draws tile.
		
		// Setting color for tile.
		draw_set_color(self.get_color());
		
		// Adding light source if this is city.
		if self.type == __TILE.CITY and (WORLD_LIGHT_ENABLED and world.__world_force_redraw_tiles){ array_push(world.__world_light_sources, _x, _y); }
		
		// Drawing rectangle.
		draw_rectangle(_x, _y, _x + WORLD_TILE_SIZE, _y + WORLD_TILE_SIZE, false);
		
		// Circle filter.
		if WORLD_TILE_FILTER_CIRCLE draw_circle(_x, _y, WORLD_TILE_FILTER_CIRCLE, false);
	}
	
	// Update color function.
	self.__update_color = function(){ // Function that updates color.
		// @function __update_color()
		// @description Function that updates color.
		
		// Returning if color optimization.
		if WORLD_TILE_COLOR_OPTIMIZATION return;
		
		// Default color.
		var _color = array_get(WORLD_TILE_COLORS, self.type);
		
		// Changing color a bit.
		_color = make_color_hsv(color_get_hue(_color), color_get_saturation(_color), color_get_value(_color) + irandom_range(-6, 6));
		
		// Setting color.
		self.color = _color;
	}
	
	self.mix = function(_left, _right, _down, _up){
		// @function mix(_left, _right, _down, _up)
		// @description Function that mixes color with merging colors.
		
		// Getting my color.
		var _color = color_get_hue(self.get_color());
		
		// Getting other colors.
		_left = _left.get_type() != self.type ? color_get_hue(_left.get_color()) : _color;
		_right = _right.get_type() != self.type ? color_get_hue(_right.get_color()) : _color;
		_down = _down.get_type() != self.type ? color_get_hue(_down.get_color()) : _color;
		_up = _up.get_type() != self.type ? color_get_hue(_up.get_color()) : _color;
		
		// Getting difference.
		_left = _left > _color ? _left - _color : _color - _left;
		_right = _right > _color ? _right - _color : _color - _right;
		_down = _down > _color ? _down - _color : _color - _down;
		_up = _up > _color ? _up - _color : _color - _up;
		
		// Getting selected color.
		var _selected = floor(max(_left, _right, _down, _up) / WORLD_COLOR_MIXING_VALUE);
		
		// Implementing color.
		self.color = make_color_hsv(color_get_hue(self.color) + _selected, color_get_saturation(self.color) + _selected, color_get_value(self.color) + _selected);
	}
	
	// Default color.
	if not WORLD_TILE_COLOR_OPTIMIZATION self.color = 0;
	
	// Setting type from constructor.
	self.type = _type;
	
	// Calling update color function.
	self.__update_color();
}

#endregion

#region City struct.

function __city() constructor{
	// City structure.
	
	self.add_tile = function(_x, _y){ // Function that adds tile to the city.
		// @function add_tile(_x, _y)
		// @description Function that adds tile to the city.
		
		if is_undefined(self.tiles){
			// If not initialised.
			
			// Initialising positions.
			self.edges[0] = _x; self.edges[2] = _x; self.edges[1] = _y; self.edges[3] = _y;
			self.tiles = [];
		}
		
		// Adding tile.
		array_push(self.tiles, [_x, _y]);
	}
	
	self.get_edges = function(){ // Function that returns edges array.
		// @function get_edges()
		// @description Function that returns edges array.
		
		// Returning.
		return self.edges;
	}
	
	self.calculate_edges = function(){ // Function that calculates edges positions.
		// @function calculate_edges()
		// @description Function that calculates edges positions.
		
		for (var _position = 0; _position < array_length(self.tiles); _position++){
			// Iterating over all positions.
			
			// Getting position.
			var _pos = self.tiles[_position],  _x = _pos[0],  _y = _pos[1];
			
			// Updating edge position if needed.
			if _x < self.edges[0]{ self.edges[0] = _x; }
			if _y < self.edges[1]{ self.edges[1] = _y; }
			if _x > self.edges[2]{ self.edges[2] = _x; }
			if _y > self.edges[3]{ self.edges[3] = _y; }
		}
		
		// Updadting right bottom edge for fix.
		self.edges[2] += WORLD_TILE_SIZE;
		self.edges[3] += WORLD_TILE_SIZE;
		
		// Deleting all tiles.
		self.tiles = undefined;
	}
	
	// City tiles.
	self.tiles = undefined;
	
	// Edges of the city.
	self.edges = [];
	
	// Name of the city.
	self.name = array_get(WORLD_CITIES_NAMES, irandom_range(0, array_length(WORLD_CITIES_NAMES) - 1));
}

#endregion

#region Functions.

#region Tile.

function __tile_world_pos_to_screen_x(_x){ // Function that converts world pos to screen x.
	// @function __tile_world_pos_to_screen_x(_x)
	// @description Function that converts world pos to screen x.
	// @param {real} _x X to convert.
	
	// Converting.
	return (_x - __world_chunk_x) * WORLD_TILE_SIZE;
}

function __tile_world_pos_to_screen_y(_y){ // Function that converts world pos to screen x.
	// @function __tile_world_pos_to_screen_x(_x)
	// @description Function that converts world pos to screen x.
	// @param {real} _x X to convert.
	
	// Converting.
	return (_y - __world_chunk_y) * WORLD_TILE_SIZE;
}

function __get_tile(_x, _y){ // Function that gets tile from the world array and returns it.
	// @function __get_tile(_x, _y)
	// @description Function that gets tile from the world array and returns it.
	
	// Returning.
	return __world[_x][_y];
}

function __set_tile(_x, _y, _tile){ // Function that sets tile to the world array.
	// @function __set_tile(_x, _y, _tile)
	// @description Function that sets tile to the world array.
	
	// Setting.
	__world[_x][_y] = _tile;
}

#endregion

#region Drawing.

function __world_draw(){ // Function that draws world.
	// @functon __world_draw()
	// @description Function that draws world.

	// Drawing tiles.
	if WORLD_TILES_ENABLED __world_draw_tiles();
	
	// Drawing light.
	if WORLD_LIGHT_ENABLED __world_draw_light();
	
	// Drawing cities.
	if WORLD_CITIES_ENABLED __world_draw_cities();
}

function __world_draw_cities(){ // Function that draws cities.
	// @function __world_draw_cities()
	// @description Function that draws cities.
	
	// Cities count.
	var _cities_count = array_length(__world_cities);
	
	for(var _city_index = 0; _city_index < _cities_count; _city_index ++){ 
		// Iterating over all cities.
		
		// Getting city.
		var _city = __world_cities[_city_index];
		
		// Getting edges.
		var _edges = _city.get_edges(); 
		_edges[0] -= __world_chunk_x * WORLD_TILE_SIZE;
		_edges[1] -= __world_chunk_y * WORLD_TILE_SIZE;
		_edges[2] -= __world_chunk_x * WORLD_TILE_SIZE;
		_edges[3] -= __world_chunk_y * WORLD_TILE_SIZE;
		
		if point_in_rectangle(mouse_x, mouse_y, _edges[0], _edges[1], _edges[2], _edges[3]){
			// If hovered.
			
			// Setting color.
			draw_set_color(c_white);
			
			if WORLD_DRAW_CITIES_SELECTION{ 
				// If selection enabled.
				
				// Drawing selection.
				draw_set_alpha(0.5);
				draw_rectangle(_edges[0], _edges[1], _edges[2], _edges[3], false);
			}
			
			// Drawing city name.
			draw_set_alpha(1);
			draw_text(mouse_x + 5, mouse_y - 10, _city.name);
			//draw_text(_edges[0] + floor((_edges[2] - _edges[0]) / 2), _edges[1] + floor((_edges[3] - _edges[1]) / 2), _city.name);
		}
	}
}

function __world_draw_light(){ // Function that draws light.
	// @function __world_draw_light()
	// @description Function that draws light.
	
	if __world_force_redraw_light or not surface_exists(__world_surface_light){
		// If should update.
		
		// Creating surface.
		if not surface_exists(__world_surface_light) __world_surface_light = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);
		
		// Setting surface tile target.
		surface_set_target(__world_surface_light);
		
		// Clearing surface.
		draw_set_alpha(1);
		gpu_set_blendmode(bm_subtract);
		draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false);
		gpu_set_blendmode(bm_normal);
	
		// Drawing black rectangle based on current light value.
		draw_set_alpha(abs(__world_lightness - (__world_lightness / 8)) / WORLD_LIGHTHNESS_MAXIMAL); 
		draw_set_color(c_black);
		draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false);
		draw_set_alpha(1);
	
		// Setting GPU blendmode to subtract.
		gpu_set_blendmode(bm_subtract);
	
		// Getting emmiters count.
		var __light_sources_count = array_length(__world_light_sources);
	
		// Setting alpha for light.
		draw_set_alpha(WORLD_LIGHT_OPACITY);
			
		for(var _light_source_index = 0; _light_source_index < __light_sources_count; _light_source_index+=2){
			// Iterating over all light sources.
		
			// Getting light source position.
			var _light_source_x = __world_light_sources[_light_source_index];
			var _light_source_y = __world_light_sources[_light_source_index + 1];
		
			// Drawing circle of light.
			draw_circle(_light_source_x, _light_source_y, WORLD_LIGHT_SIZE * WORLD_TILE_SIZE, false);
		}
		
		// Drawing flashlight.
		if WORLD_DRAW_MOUSE_FLASHLIGHT draw_circle(mouse_x, mouse_y, WORLD_DRAW_MOUSE_FLASHLIGHT, false);
		
		// Setting draw settings back to normal.
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	
		// Resetting surface target.
		surface_reset_target();
	}
	
	// Drawing surface.
	draw_surface(__world_surface_light, 0, 0);
	
	// Disabling light update.
	if not WORLD_FORCE_REDRAW_LIGHT __world_force_redraw_light = false; 
	
}

function __world_draw_tiles(){ // Function that draw tiles.
	// @function __world_draw_tiles()
	// @description Function that draw tiles.
	
	if __world_force_redraw_tiles or not surface_exists(__world_surface_tiles){
		// If should update.
		
		// Deleting all light sources.
		__world_light_sources = [];
		
		// Creating surface.
		if not surface_exists(__world_surface_tiles) __world_surface_tiles = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);
		
		// Setting surface tile target.
		surface_set_target(__world_surface_tiles);
		
		for(var _x = __world_chunk_x; _x < __world_chunk_x + CHUNK_WIDTH; _x ++)
			for(var _y = __world_chunk_y; _y < __world_chunk_y + CHUNK_HEIGHT; _y ++){
				// Iterating over all tiles in the screen chunk.
			
				// Drawing tile.
				__get_tile(_x,_y).draw(__tile_world_pos_to_screen_x(_x), __tile_world_pos_to_screen_y(_y));
			}
		
		// Resetting surface target.
		surface_reset_target();
	}
	
	// Drawing surface.
	draw_surface(__world_surface_tiles, 0, 0);
	
	// Disabling redraw.
	if not WORLD_FORCE_REDRAW_TILES __world_force_redraw_tiles = false;
}

#endregion

#region Updating.

function __world_update_time(){ // Function that updates time.
	// @function __world_update_time()
	// @description Function that updates time.
	
	// Updating light value by direction.
	__world_lightness += __world_lightness_change / 4;
	
	// Changing direction if reached max value.
	if __world_lightness == WORLD_LIGHTHNESS_MAXIMAL or __world_lightness == -WORLD_LIGHTHNESS_MAXIMAL{
		__world_lightness_change = -__world_lightness_change;
	}
}

function __world_update_movement(){ // Function that updates movement.
	// @function __world_update_movement()
	// @description Function that updates movement.
	
	// X and Y speed.
	var _xspeed = (keyboard_check(vk_right) - keyboard_check(vk_left));
	var _yspeed = (keyboard_check(vk_down) - keyboard_check(vk_up));
	
	// Changing chunk position.
	__world_chunk_x = clamp(__world_chunk_x + _xspeed, 0, WORLD_WIDTH - CHUNK_WIDTH);
	__world_chunk_y = clamp(__world_chunk_y + _yspeed, 0, WORLD_HEIGHT - CHUNK_HEIGHT);
	
	// Forcing to redraw if moved.
	if _xspeed != 0 or _yspeed != 0{
		__world_force_redraw_tiles = true;
		__world_force_redraw_light = true;
	}
	
}

function __world_update_placement(){ // Function that updates placement.
	// @function __world_update_placement()
	// @description Function that updates placement.
	
	if mouse_check_button(mb_left){
		// If clicked.
		
		// Getting placement position for grid.
		var _x = mouse_x div WORLD_TILE_SIZE + __world_chunk_x;
		var _y = mouse_y div WORLD_TILE_SIZE + __world_chunk_y;
		
		// Tiles for placement.
		var _tiles = [];
		
		// Getting tile array.
		for(var _index = 0; _index < sqr(WORLD_PLACEMENT_SIZE); _index ++){
			// Iterating over placement size (SIZE ** SIZE)
			
			// Getting position.
			var _tx = _x + _index mod WORLD_PLACEMENT_SIZE - floor(WORLD_PLACEMENT_SIZE / 2);
			var _ty = _y + _index div WORLD_PLACEMENT_SIZE - floor(WORLD_PLACEMENT_SIZE / 2);
			
			// Passing if overworld.
			if _tx < 0 or _tx > WORLD_WIDTH or _ty < 0 or _ty > WORLD_HEIGHT continue;
			
			// Adding to array.
			array_push(_tiles, __get_tile(_tx, _ty));
		}
		
		for (var _tile_index = 0; _tile_index < array_length(_tiles); _tile_index++){
			// For all tiles.
			
			// Get tile.
			var _tile = _tiles[_tile_index];
			
			// Setting new type.
			_tile.set_type(WORLD_PLACEMENT_TILE);
		
			// Passing if overworld.
			if _x < 1 or _x > WORLD_WIDTH - 1 or _y < 1 or _y > WORLD_HEIGHT - 1 continue;
			
			// Mixing. (WARNING THERE IS A BUG WITH OVERFLOW)!
			_tile.mix(__get_tile(_x - 1, _y), __get_tile(_x + 1, _y), __get_tile(_x, _y + 1), __get_tile(_x, _y - 1));
		}
		
		// Forcing to redraw.
		__world_force_redraw_tiles = true;
		__world_force_redraw_light = true;
	}
}

function __world_update(){ // Function that updates world.
	// @function __world_update()
	// @description Function that updates world.
	
	// Updating time.
	if WORLD_UPDATE_TIME __world_update_time();
	
	// Updating movement.
	if WORLD_ALLOW_MOVEMENT __world_update_movement()
	
	// Updating placement.
	if WORLD_ALLOW_PLACEMENT __world_update_placement();
}

#endregion

#region Generation.

function __world_generate(){ // Function that generates world.
	// @functon __world_generate()
	// @description Function that generates world.
	
	// Randomizing.
	randomize();
	
	// Filling.
	for (var _x = 0; _x < WORLD_WIDTH; _x++)
		for (var _y = 0; _y < WORLD_HEIGHT; _y++){
			// Iteraing over all __WORLD_SIZE.
			
			// Setting tile as forest.
			__set_tile(_x, _y, new __tile(WORLD_GENERATOR_DEFAULT_TILE));
		};
		
	// Worms.
	for(var _chunk_x = 0; _chunk_x <= WORLD_WIDTH; _chunk_x += WORLD_GENERATOR_CHUNK_SIZE)
		for(var _chunk_y = 0; _chunk_y <= WORLD_HEIGHT; _chunk_y += WORLD_GENERATOR_CHUNK_SIZE){
			// Iterating over chunk.
			
			// Generating deserts and oceans.
			__generator_generate_worm(__TILE.DESERT, irandom_range(50, 100), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			__generator_generate_worm(__TILE.WATER, irandom_range(50, 100), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			
			// Generating worms (Cities, water)
			repeat(WORLD_GENERATOR_CHUNK_WORMS){ 
				__generator_generate_worm(__TILE.WATER, irandom_range(3, 10), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), false); 
				__generator_generate_worm(__TILE.CITY, irandom_range(10, 15), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
				
			}
		}
		
	
	// Returning if dont need to mix.
	if WORLD_TILE_COLOR_OPTIMIZATION or not WORLD_COLOR_MIX return;
	
	for (var _x = 0; _x < WORLD_WIDTH; _x++)
		for (var _y = 0; _y < WORLD_HEIGHT; _y++){
			// Iteraing over all world.
			
			// Continue if overflow.
			if (_x < 2 or _x > WORLD_WIDTH - 2 or _y < 2 or _y > WORLD_HEIGHT - 2) continue;
			
			// Mixing tile.
			__get_tile(_x, _y).mix(__get_tile(_x - 1, _y), __get_tile(_x + 1, _y), __get_tile(_x, _y + 1), __get_tile(_x, _y - 1));
		};
}

function __generator_generate_worm(_fill, _size, _x, _y, _nooverflow){ // Function that generates random worm with given tile size and position.
	// @function __generator_generate_worm(_fill, _size, _x, _y, _nooverflow)
	// @description Function that generates random worm with given tile size and position.
	
	// Getting city struct if needed.
	var _city = (_fill == __TILE.CITY and WORLD_CITIES_ENABLED) ? new __city() : undefined;
	
	for (var _repeat = 0; _repeat < _size; _repeat++){
		// Loop for size.
		
		// Not set if not on world pos.
		if _x < 0 or _y < 0 or _x >= WORLD_WIDTH or _y >= WORLD_HEIGHT continue;
		
		// Getting tile.
		var _tile = __get_tile(_x, _y);
		
		if not _nooverflow or _tile.get_type() != _fill{ 
			// If should place tile.
			
			// Setting tile.
			_tile.set_type(_fill); 
			
			// Adding tile to the city if needed.
			if not is_undefined(_city) _city.add_tile(__tile_world_pos_to_screen_x(_x), __tile_world_pos_to_screen_y(_y));
		}
		
		// Moving.
		_x += irandom_range(-1, 1);
		_y += irandom_range(-1, 1);
		
		// Increasing size if not moved.
		if _x == 0 and _y == 0 _size++;
	}
	
	if not is_undefined(_city){
		// If city is generated.
		
		// Calculating edges.
		_city.calculate_edges();
		
		// Adding to all cities array.
		array_push(__world_cities, _city);
	}
}

#endregion

#endregion

#region Entry point.

// Generating world.
__world_generate();

// Enabling overlay.
show_debug_overlay(true);

#endregion