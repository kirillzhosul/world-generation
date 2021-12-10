/// @description Initialising world.
/// @author Kirill Zhosul (@kirillzhosul)

// This is not refactored code.
// This code should be refactored later,
// Now there is some things that may be bad / should be reworked / renamed.
// Sorry for that.

#region Functions.

#region Tile.

function tile_world_pos_to_screen_x(pos_x){
	// Converting.
	return (pos_x - chunk_x) * WORLD_TILE_SIZE;
}

function tile_world_pos_to_screen_y(pos_y){ 
	// Converting.
	return (pos_y - chunk_y) * WORLD_TILE_SIZE;
}

function get_tile(tile_x, tile_y){
	// @description Function that gets tile from the world array and returns it.
	
	// Returning.
	return tiles[tile_x][tile_y];
}

function set_tile(tile_x, tile_y, tile){
	// @description Function that sets tile to the world array.
	
	// Setting.
	tiles[tile_x][tile_y] = tile;
}

#endregion

#region Drawing.

function world_draw(){
	// @description Draws world.

	if WORLD_TILES_ENABLED world_draw_tiles();
	if WORLD_LIGHT_ENABLED world_draw_light();
	if WORLD_CITIES_ENABLED world_draw_cities();
}

function world_draw_cities(){ // Function that draws cities.
	// @function world_draw_cities()
	// @description Function that draws cities.
	
	// Cities count.
	var cities_count = array_length(cities);
	
	for(var city_index = 0; city_index < cities_count; city_index ++){ 
		// Iterating over all cities.
		
		// Getting city.
		var city = cities[city_index];
		
		// Getting edges.
		var edges = city.get_edges(); 
		edges[0] = (edges[0] - chunk_x) * WORLD_TILE_SIZE;
		edges[1] = (edges[1] - chunk_y) * WORLD_TILE_SIZE;
		edges[2] = (edges[2] - chunk_x) * WORLD_TILE_SIZE;
		edges[3] = (edges[3] - chunk_y) * WORLD_TILE_SIZE;
		
		if point_in_rectangle(mouse_x, mouse_y, edges[0], edges[1], edges[2], edges[3]){
			// If hovered.
			
			// Setting color.
			draw_set_color(c_white);
			
			if WORLD_DRAW_CITIES_SELECTION{ 
				// If selection enabled.
				
				// Drawing selection.
				draw_set_alpha(0.5);
				draw_rectangle(edges[0], edges[1], edges[2], edges[3], false);
			}
			
			// Drawing city name.
			draw_set_alpha(1);
			
			// This code implements drwaing of the city name in the mouse position.
			draw_text(mouse_x + 5, mouse_y - 10, "City.\nName: " + city.name + "\nSize (Tiles): " + string(city.get_size()));
		}
	}
}

function world_draw_light(){ // Function that draws light.
	// @function world_draw_light()
	// @description Function that draws light.
	
	if should_redraw_light or not surface_exists(surface_light){
		// If should update.
		
		// Creating surface.
		if not surface_exists(surface_light) surface_light = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);
		
		// Setting surface tile target.
		surface_set_target(surface_light);
		
		// Clearing surface.
		draw_set_alpha(1);
		gpu_set_blendmode(bm_subtract);
		draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false);
		gpu_set_blendmode(bm_normal);
	
		// Drawing black rectangle based on current light value.
		draw_set_alpha(abs(light_level - (light_level / 8)) / WORLD_LIGHTHNESS_MAXIMAL); 
		draw_set_color(c_black);
		draw_rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, false);
		draw_set_alpha(1);
	
		// Setting GPU blendmode to subtract.
		gpu_set_blendmode(bm_subtract);
	
		// Getting emmiters count.
		var light_sources_count = array_length(light_sources);
	
		// Setting alpha for light.
		draw_set_alpha(WORLD_LIGHT_OPACITY);
			
		for(var light_source_index = 0; light_source_index < light_sources_count; light_source_index+=2){
			// Iterating over all light sources.
		
			// Getting light source position.
			var source_x = light_sources[light_source_index];
			var source_y = light_sources[light_source_index + 1];
		
			// Drawing circle of light.
			draw_circle(source_x, source_y, WORLD_LIGHT_SIZE * WORLD_TILE_SIZE, false);
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
	draw_surface(surface_light, 0, 0);
	
	// Disabling light update.
	if not WORLD_FORCE_REDRAW_LIGHT should_redraw_light = false; 
}

function world_draw_tiles(){ // Function that draw tiles.
	// @function world_draw_tiles()
	// @description Function that draw tiles.
	
	if should_redraw_tiles or not surface_exists(surface_tiles){
		// If should update.
		
		// Deleting all light sources.
		light_sources = [];
		
		// Creating surface.
		if not surface_exists(surface_tiles) surface_tiles = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT);
		
		// Setting surface tile target.
		surface_set_target(surface_tiles);
		
		for(var tile_x = chunk_x; tile_x < chunk_x + CHUNK_WIDTH; tile_x++)
			for(var tile_y = chunk_y; tile_y < chunk_y + CHUNK_HEIGHT; tile_y++){
				// Iterating over all tiles in the screen chunk.
			
				// Getting tile.
				var tile = get_tile(tile_x, tile_y);
				
				// Drawing tile.
				tile.draw(tile_world_pos_to_screen_x(tile_x), tile_world_pos_to_screen_y(tile_y));
				
				if tile.type == eTILE_TYPE.CITY and (WORLD_LIGHT_ENABLED and should_redraw_tiles){ 
					// If this is city, light is enabled, and we should be forced to draw tiles.
					
					// Add light source.
					array_push(light_sources, tile_x, tile_y); 
				}
		
			}
		
		// Resetting surface target.
		surface_reset_target();
	}
	
	// Drawing surface.
	draw_surface(surface_tiles, 0, 0);
	
	// Disabling redraw.
	if not WORLD_FORCE_REDRAW_TILES should_redraw_tiles = false;
}

#endregion

#region Updating.

function world_update_time(){ // Function that updates time.
	// @function world_update_time()
	// @description Function that updates time.
	
	// Updating light value by direction.
	light_level += light_update_direction / 4;
	
	// Changing direction if reached max value.
	if light_level == WORLD_LIGHTHNESS_MAXIMAL or light_level == -WORLD_LIGHTHNESS_MAXIMAL{
		light_update_direction = -(light_update_direction);
	}
}

function world_update_movement(){ // Function that updates movement.
	// @function world_update_movement()
	// @description Function that updates movement.
	
	// X and Y speed.
	var x_speed = (keyboard_check(vk_right) - keyboard_check(vk_left));
	var y_speed = (keyboard_check(vk_down) - keyboard_check(vk_up));
	
	// Changing chunk position.
	chunk_x = clamp(chunk_x + x_speed, 0, WORLD_WIDTH - CHUNK_WIDTH);
	chunk_y = clamp(chunk_y + y_speed, 0, WORLD_HEIGHT - CHUNK_HEIGHT);
	
	// Forcing to redraw if moved.
	if x_speed != 0 or y_speed != 0{
		should_redraw_light = true;
		should_redraw_tiles = true;
	}
}

function world_update_placement(){
	// @description Updates placement in the world.
	
	// Returning if mouse is not pressed.
	if not mouse_check_button(mb_left) return;
	
	// Getting placement position for grid.
	var place_x = mouse_x div WORLD_TILE_SIZE + chunk_x;
	var place_y = mouse_y div WORLD_TILE_SIZE + chunk_y;
		
	// Tiles for placement.
	var place_tiles = [];
		
	// Getting tile array.
	for(var place_index = 0; place_index < sqr(WORLD_PLACEMENT_SIZE); place_index ++){
		// Iterating over placement size (SIZE ** SIZE)
			
		// Getting position.
		var square_x = place_x + place_index mod WORLD_PLACEMENT_SIZE - floor(WORLD_PLACEMENT_SIZE / 2);
		var square_y = place_y + place_index div WORLD_PLACEMENT_SIZE - floor(WORLD_PLACEMENT_SIZE / 2);
			
		// Passing if overworld.
		if square_x < 0 or square_x > WORLD_WIDTH or square_y < 0 or square_y > WORLD_HEIGHT continue;
			
		// Getting tile.
		var square_tile = get_tile(square_x, square_y);
				
		// Try get city
		var square_city = square_tile.try_get_city();
				
		if not is_undefined(square_city){
			// If there is an city in the placement.

			// Removing this tile from the city structure.
			square_city.remove_tile(square_x, square_y);
		}
			
		// Adding to array.
		array_push(place_tiles, square_tile);
	}
		
	for (var tile_index = 0; tile_index < array_length(place_tiles); tile_index++){
		// For all tiles.
			
		// Get tile.
		var place_tile = place_tiles[tile_index];
			
		// Setting new type.
		place_tile.set_type(WORLD_PLACEMENT_TILE);
		
		// Passing if overworld.
		if place_x < 1 or place_x > WORLD_WIDTH - 1 or place_y < 1 or place_y > WORLD_HEIGHT - 1 continue;
			
		// Mixing.
		place_tile.mix_color(
			get_tile(place_x - 1, place_y), 
			get_tile(place_x + 1, place_y), 
			get_tile(place_x, place_y + 1), 
			get_tile(place_x, place_y - 1)
		);
	}
		
	// Forcing to redraw.
	should_redraw_light = true;
	should_redraw_tiles = true;
}

function world_update(){
	// @description Updates world. 
	
	// Updating.
	if WORLD_UPDATE_TIME world_update_time();
	if WORLD_ALLOW_MOVEMENT world_update_movement();
	if WORLD_ALLOW_PLACEMENT world_update_placement();
}
	
#endregion

#region Generation.

function world_generate(){ // Function that generates world.
	// @functon world_generate()
	// @description Function that generates world.
	
	// Randomizing.
	randomize();
	
	// Filling.
	for (var world_x = 0; world_x < WORLD_WIDTH; world_x++){
		for (var world_y = 0; world_y < WORLD_HEIGHT; world_y++){
			// Iteraing over all WORLD_SIZE.
			
			// Setting tile as forest.
			set_tile(world_x, world_y, new sTile(WORLD_GENERATOR_DEFAULT_TILE));
		};
	}
	
	// Worms.
	for(var worm_chunk_x = 0; worm_chunk_x <= WORLD_WIDTH; worm_chunk_x += WORLD_GENERATOR_CHUNK_SIZE)
		for(var worm_chunk_y = 0; worm_chunk_y <= WORLD_HEIGHT; worm_chunk_y += WORLD_GENERATOR_CHUNK_SIZE){
			// Iterating over chunk.
			
			// Generating deserts and oceans.
			generator_generate_worm(eTILE_TYPE.DESERT, 
				irandom_range(50, 100), irandom_range(worm_chunk_x, worm_chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(worm_chunk_y, worm_chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			generator_generate_worm(eTILE_TYPE.WATER, 
				irandom_range(50, 100), irandom_range(worm_chunk_x, worm_chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(worm_chunk_y, worm_chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			
			// Generating worms (Cities, water)
			repeat(WORLD_GENERATOR_CHUNK_WORMS){ 
				generator_generate_worm(eTILE_TYPE.WATER, 
					irandom_range(3, 10), irandom_range(worm_chunk_x, worm_chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(worm_chunk_y, worm_chunk_y + WORLD_GENERATOR_CHUNK_SIZE), false); 
				generator_generate_worm(eTILE_TYPE.CITY, 
					irandom_range(10, 15), irandom_range(worm_chunk_x, worm_chunk_x + WORLD_GENERATOR_CHUNK_SIZE), irandom_range(worm_chunk_y, worm_chunk_y + WORLD_GENERATOR_CHUNK_SIZE), true); 
			}
		}
	
	// Returning if dont need to mix.
	if WORLD_TILE_COLOR_OPTIMIZATION or not WORLD_COLOR_MIX return;
	
	for (var world_x = 0; world_x < WORLD_WIDTH; world_x++)
		for (var world_y = 0; world_y < WORLD_HEIGHT; world_y++){
			// Iteraing over all world.
			
			// Continue if overflow.
			if (world_x < 2 or world_x > WORLD_WIDTH - 2 or world_y < 2 or world_y > WORLD_HEIGHT - 2) continue;
			
			// Mixing tile.
			get_tile(world_x, world_y).mix_color(
				get_tile(world_x - 1, world_y), 
				get_tile(world_x + 1, world_y),
				get_tile(world_x, world_y + 1), 
				get_tile(world_x, world_y - 1)
			);
		};
}

function generator_generate_worm(fill_cell_type, size, worm_x, worm_y, no_overflow){
	// @description Function that generates random worm with given tile size and position.
	
	// Getting city struct if needed.
	var current_city = (fill_cell_type == eTILE_TYPE.CITY and WORLD_CITIES_ENABLED) ? new sCity() : undefined;
	
	for (var _repeat = 0; _repeat < size; _repeat++){
		// Loop for size.
		
		// Not set if not on world pos.
		if worm_x < 0 or worm_y < 0 or worm_x >= WORLD_WIDTH or worm_y >= WORLD_HEIGHT continue;
		
		// Getting tile.
		var current_tile = get_tile(worm_x, worm_y);
		
		if not no_overflow or current_tile.get_type() != fill_cell_type{ 
			// If should place tile.
			
			// Setting tile.
			current_tile.set_type(fill_cell_type); 
			
			if not is_undefined(current_city){
				// If any city connected.
				
				// Adding tile to the city if needed.
				current_city.add_tile(worm_x, worm_y);
				
				// Marking tile as city.
				current_tile.set_city(current_city);
			}
		}

		// Moving.
		worm_x += irandom_range(-1, 1);
		worm_y += irandom_range(-1, 1);
		
		// Increasing size if not moved.
		if worm_x == 0 and worm_y == 0 size++;
	}
	
	if not is_undefined(current_city){
		// If city is generated.
		
		// Calculating edges.
		current_city.calculate_edges();
		
		// Adding to all cities array.
		array_push(cities, current_city);
	}
}

#endregion

#endregion

// Flags for redrawing.
should_redraw_tiles = true; // If true, this is will redraw tiles on next draw call (And set back to false).
should_redraw_light = true; // If true, this is will redraw light on next draw call (And set back to false).

// How much light in the world now.
light_level = WORLD_LIGHTHNESS_MAXIMAL;

// By how light_level changes when updating time.
light_update_direction = -1;

// Sources of the light.
light_sources = []

// Surfaces of the world.
surface_tiles = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT); // Surface with tiles.
surface_light = surface_create(SCREEN_WIDTH, SCREEN_HEIGHT); // Surface with light.

// Position of the world chunk to draw.
chunk_x = 0;
chunk_y = 0;

// Arrays of the world.
cities = []; // Array of world cities.
tiles = []; // Array of the world tiles.

// Generating world.
world_generate();

// Enabling overlay.
show_debug_overlay(true);