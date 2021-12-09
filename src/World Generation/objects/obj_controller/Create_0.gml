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

// How much frames left to call cities grow update.
//__world_cities_grow_update_time_left = WORLD_CITIES_GROW_SPEED;

// Array of the world.
__world = [];

#endregion

#region City struct.

function sCity() constructor{
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
	
	self.remove_tile = function(_x, _y, _recalculate_edges, _allow_multi){
		// @function remove_tile(_x, _y)
		// @description Function that removes tile from the city.
		// @param _x X of the tile.
		// @param _y Y of the tile.
		// @param _recalculate_edges Should we recalculate edges after this?
		// @param _allow_multi Allow removing more than one tile?
		
		// Getting tiles count.
		var _tiles_count = array_length(self.tiles);
		
		for (var _tile_index = 0; _tile_index < _tiles_count; _tile_index++){
			// Iterating over all tiles.
			
			// Getting position.
			var _position = self.tiles[_tile_index];
			
			if _position[0] == _x and _position[1] == _y{
				// If correct position.
				
				// Deleting tile.
				array_delete(self.tiles, _tile_index, 1);
				
				// Returning if we dont allow to remove more than 1 tile.
				if not _allow_multi return;
			}
		}
		
		// Recalculating edges if we want.
		if _recalculate_edges self.calculate_edges();
	}
	
	self.get_edges = function(){ // Function that returns edges array.
		// @function get_edges()
		// @description Function that returns edges array.
		
		// Returning.
		return self.edges;
	}
	
	self.get_size = function(){
		// @function get_size()
		// @description Function that returns city size.
		// @returns {real} Size.
		
		// If we not set any tiles for now - return 0.
		if is_undefined(self.tiles) return 0;
		
		// Returning.
		return array_length(self.get_edges());
	}
	
	/*
	self.process_tile_build = function(_x, _y){
		// @function process_tile_build(_x, y)
		// @description Function that process tile building at the new tiles.
		
		// Getting tile.
		var _tile = obj_controller.__get_tile(_x, _y);
		
		if not (_tile.is_city() and _tile.get_city() == self){
			// If tile is not city or not our city.
			
			// Returning.
			return;
		}
		
		// Getting tile type.
		var _type = _tile.get_type();
		
		// Setting new type (CITY if default and CITY_ON_WATER if on water).
		_tile.set_type(_type == eTILE_TYPE.WATER ? eTILE_TYPE.CITY_ON_WATER : eTILE_TYPE.CITY);
	}
	self.process_growing = function(){
		// @function process_growing()
		// @description Function that processes growing of the city.
		
		// Returning if not allowed to grow.
		if not WORLD_CITIES_GROWING_ALLOWED return;
		
		// Getting growing sides x.
		var _grow_side_x = choose(-1, 0, 1);
		var _grow_side_y = choose(-1, 0, 1);
		
		// Getting tiles count.
		var _tiles_count = array_length(self.tiles);
		
		// ASAP REWRITE TO INTERNAL GROW SIDE CHECK.
		// How much tiles we grow.
		var _grow_tiles = 0;
		
		
		for (var _position = 0; _position < _tiles_count; _position++){
			// Iterating over all positions.
			
			// Getting position.
			var _pos = self.tiles[_position]
			var _x = _pos[0];
			var _y = _pos[1];
			
			if (_y == self.edges[1] or _y == self.edges[3]){
				// If we on the same line (Y).
				if (_x >= self.edges[0] and _x < self.edges[3]){
					// If we on the same line (X).
					
					if choose(true, false, false, false){
						// If 1/4 chance (25%) - place there our city.
						
						// Getting new positions.
						var _new_x = _x + _grow_side_x;
						var _new_y = _y + _grow_side_y;
						
						// Adding tile.
						var _tile = controller.__get_tile(_new_x, _new_y);
						if not _tile.is_city(){
							// If this is correct tile (not already city..
							
							// Adding.
							self.add_tile(_new_x, _new_y);
						}else{
							// If incorrect tile.
							
							// Continue.
							continue;
						}
						
						// Processing building of the tile.
						self.process_tile_build(_new_x, _new_y);
						
						// Recalculating edges.
						self.calculate_edges();
						
						if _grow_tiles + 1 < WORLD_CITIES_GROWING_SIZE{
							// If we grow more.
							
							// Getting new growing sides x.
							var _grow_side_x = choose(-1, 0, 1);
							var _grow_side_y = choose(-1, 0, 1);
							
							// Increasing growing amount.
							_grow_tiles ++;
						}else{
							// If we grow need size.
							
							// Returning.
							return;
						}
					}
				}
			}
		}
	}
	*/
	self.calculate_edges = function(){ // Function that calculates edges positions.
		// @function calculate_edges()
		// @description Function that calculates edges positions.
		
		// If we not set any tiles for now - return.
		if is_undefined(self.tiles) return;
		
		// Gettin position of the first tile.
		var _pos = self.tiles[0]; 
		var _x = _pos[0];
		var _y = _pos[1];
		
		// Setting default edges.
		self.edges[0] = _x; 
		self.edges[2] = _x; 
		self.edges[1] = _y; 
		self.edges[3] = _y;
		
		// Getting tiles count.
		var _tiles_count = array_length(self.tiles);
		
		for (var _position = 0; _position < _tiles_count; _position++){
			// Iterating over all positions.
			
			// Getting position.
			var _pos = self.tiles[_position]
			var _x = _pos[0];
			var _y = _pos[1];
			
			// Updating edge position if needed.
			if _x < self.edges[0]{ self.edges[0] = _x; }
			if _y < self.edges[1]{ self.edges[1] = _y; }
			if _x > self.edges[2]{ self.edges[2] = _x; }
			if _y > self.edges[3]{ self.edges[3] = _y; }
		}
		
		// Updadting right bottom edge for fix.
		//self.edges[2] += WORLD_TILE_SIZE;
		//self.edges[3] += WORLD_TILE_SIZE;
	}
	
	self.get_center_x = function(){
		// @function get_center_x()
		// @description Function that returns x of the city center.
		
		// Returning x.
		return self.edges[0] + floor((self.edges[2] - self.edges[0]) / 2)
	}
	
	self.get_center_y = function(){
		// @function get_center_y()
		// @description Function that returns y of the city center.
		
		// Returning y.
		return self.edges[1] + floor((self.edges[3] - self.edges[1]) / 2)
	}
		
	// City tiles.
	self.tiles = undefined;
	
	// Edges of the city.
	self.edges = [0, 0, 0, 0];
	
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

function world_draw(){ // Function that draws world.
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
		_edges[0] = (_edges[0] - __world_chunk_x) * WORLD_TILE_SIZE;
		_edges[1] = (_edges[1] - __world_chunk_y) * WORLD_TILE_SIZE;
		_edges[2] = (_edges[2] - __world_chunk_x) * WORLD_TILE_SIZE;
		_edges[3] = (_edges[3] - __world_chunk_y) * WORLD_TILE_SIZE;
		
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
			
			// This code implements drwaing of the city name in the mouse position.
			draw_text(mouse_x + 5, mouse_y - 10, "City.\bName: " + _city.name + "\nSize (Tiles): " + string(_city.get_size()));
			// This code implements drawing of the city name in the center of the city.
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
			
				var tile = __get_tile(_x,_y);
				// Drawing tile.
				tile.draw(__tile_world_pos_to_screen_x(_x), __tile_world_pos_to_screen_y(_y));
				
						
				if tile.type == eTILE_TYPE.CITY and (WORLD_LIGHT_ENABLED and __world_force_redraw_tiles){ 
					// If this is city, light is enabled, and we should be forced to draw tiles.
					
					// Add light source.
					array_push(__world_light_sources, _x, _y); 
				}
		
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
		__world_lightness_change = -(__world_lightness_change);
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
			
			// Getting tile.
			var _tile = __get_tile(_tx, _ty);
				
			// Try get city
			var _city = _tile.get_city();
				
			if not is_undefined(_city){
				// If there is an city in the placement.

				// Removing this tile from the city structure.
				_city.remove_tile(_tx, _ty, true, false);
			}
			
			// Adding to array.
			array_push(_tiles, _tile);
		}
		
		for (var _tile_index = 0; _tile_index < array_length(_tiles); _tile_index++){
			// For all tiles.
			
			// Get tile.
			var _tile = _tiles[_tile_index];
			
			// Setting new type.
			_tile.set_type(WORLD_PLACEMENT_TILE);
		
			// Passing if overworld.
			if _x < 1 or _x > WORLD_WIDTH - 1 or _y < 1 or _y > WORLD_HEIGHT - 1 continue;
			
			// Mixing.
			_tile.mix_color(__get_tile(_x - 1, _y), __get_tile(_x + 1, _y), __get_tile(_x, _y + 1), __get_tile(_x, _y - 1));
		}
		
		// Forcing to redraw.
		__world_force_redraw_tiles = true;
		__world_force_redraw_light = true;
	}
}

function world_update(){ // Function that updates world.
	// @function __world_update()
	// @description Function that updates world.
	
	// Updating time.
	if WORLD_UPDATE_TIME __world_update_time();
	
	// Updating movement.
	if WORLD_ALLOW_MOVEMENT __world_update_movement();
	
	// Updating placement.
	if WORLD_ALLOW_PLACEMENT __world_update_placement();
	
	// Updating cities growing.
	//if WORLD_CITIES_GROW_SPEED __world_update_cities_grow();
}

/*
function __world_update_cities_grow(){
	// @function __world_update_cities_grow()
	// @description Function that updates cities grow.
	

	if __world_cities_grow_update_time_left == 0{
		// If update time.
		
		// Resetting next update time.
		//__world_cities_grow_update_time_left = WORLD_CITIES_GROW_SPEED;
		
		for(var _city_index=0; _city_index < array_length(__world_cities);_city_index++){
			var _city = array_get(__world_cities, _city_index)
			_city.process_growing();
		}
	}else{
		// If not update time.
		
		// Decreasing update left time.
		__world_cities_grow_update_time_left --;
	}

}
*/
	
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
			__set_tile(_x, _y, new sTile(WORLD_GENERATOR_DEFAULT_TILE));
		};
		
	// Worms.
	for(var _chunk_x = 0; _chunk_x <= WORLD_WIDTH; _chunk_x += WORLD_GENERATOR_CHUNK_SIZE)
		for(var _chunk_y = 0; _chunk_y <= WORLD_HEIGHT; _chunk_y += WORLD_GENERATOR_CHUNK_SIZE){
			// Iterating over chunk.
			
			// Generating deserts and oceans.
			__generator_generate_worm(eTILE_TYPE.DESERT, irandom_range(50, 100), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			__generator_generate_worm(eTILE_TYPE.WATER, irandom_range(50, 100), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			
			// Generating worms (Cities, water)
			repeat(WORLD_GENERATOR_CHUNK_WORMS){ 
				__generator_generate_worm(eTILE_TYPE.WATER, irandom_range(3, 10), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), false); 
				__generator_generate_worm(eTILE_TYPE.CITY, irandom_range(10, 15), irandom_range(_chunk_x, _chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(_chunk_y, _chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
				
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
			__get_tile(_x, _y).mix_color(__get_tile(_x - 1, _y), __get_tile(_x + 1, _y), __get_tile(_x, _y + 1), __get_tile(_x, _y - 1));
		};
}

function __generator_generate_worm(_fill, _size, _x, _y, _nooverflow){ // Function that generates random worm with given tile size and position.
	// @function __generator_generate_worm(_fill, _size, _x, _y, _nooverflow)
	// @description Function that generates random worm with given tile size and position.
	
	// Getting city struct if needed.
	var _city = (_fill == eTILE_TYPE.CITY and WORLD_CITIES_ENABLED) ? new sCity() : undefined;
	
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
			
			if not is_undefined(_city){
				// If any city connected.
				
				// Adding tile to the city if needed.
				_city.add_tile(_x, _y);
				
				// Marking tile as city.
				_tile.set_city(_city);
			}
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