/// @description City structure implementation.
// @author Kirill Zhosul (@kirillzhosul)

function sCity() constructor{
	// City constructor.
	// Contains implementation of the city structure.
	
	// Array of the city tiles.
	// Undefined is the one of the states,
	// If tiles is undefined, structure will work as should (Non-initialised array).
	// And when you will add tiles using `add_tile()`, it will be initalised.
	self._tiles = undefined;
	
	// Default edges of the city.
	self._edges = [0, 0, 0, 0];

	// Name of the city.
	// Grabbing random name from the names array.
	self.name = array_get(WORLD_CITIES_NAMES, irandom_range(0, array_length(WORLD_CITIES_NAMES) - 1));
	
	// Edges getter / setter.
	self.get_edges = function(){
		// @description Getter for edges.
		// @returns {array} Value.
		
		// Returning.
		return self._edges;
	}
	self.calculate_edges = function(){
		// @description Calculates edges positions.
		
		// If we not set any tiles for now - just return.
		if (is_undefined(self.tiles)) return;
		
		// Gettin position of the first tile.
		var pos = self.tiles[0]; 
		var pos_x = pos[0];
		var pos_y = pos[1];
		
		// Setting default edges.
		self.edges[0] = pos_x; 
		self.edges[2] = pos_x; 
		self.edges[1] = pos_y; 
		self.edges[3] = pos_y;
		
		// Getting tiles count.
		var tiles_count = array_length(self.tiles);
		
		for (var position = 0; position < tiles_count; position++){
			// Iterating over all positions.
			
			// Getting position.
			pos = self.tiles[position];
			pos_x = pos[0];
			pos_y = pos[1];
			
			// Updating edge position if needed.
			if (pos_x < self.edges[0]) self.edges[0] = pos_x;
			if (pos_y < self.edges[1]) self.edges[1] = pos_y;
			if (pos_x > self.edges[2]) self.edges[2] = pos_x;
			if (pos_y > self.edges[3]) self.edges[3] = pos_y;
		}
	}
		
	// Size getter.
	self.get_size = function(){
		// @description Getter for size.
		// @returns {real} Value.
		
		// Return NULL (0), as there is no tiles (undefined tiles array).
		if (is_undefined(self._tiles)) return 0;
		
		// Returning.
		return array_length(self.get_edges());
	}
	
	// Tile setter / getter.
	self.add_tile = function(add_x, add_y){
		// @description Adds tile position to the tiles.
		// @param {real} add_x X of the tile.
		// @param {real} add_y Y of the tile.
		
		if (is_undefined(self.tiles)){
			// If array tiles is not initailised.
			
			// Initialise edges.
			self.edges[0] = add_x; 
			self.edges[1] = add_y;
			self.edges[2] = add_x; 
			self.edges[3] = add_y;
			
			// Iinitalise edges.
			self.tiles = [];
		}
		
		// Adding tile position to the tiles.
		array_push(self.tiles,
			[add_x, add_y]
		);
	}
	self.remove_tile = function(remove_x, remove_y){
		// @description Function that removes tile from the city.
		// @param {real} x X of the tile.
		// @param {real} y Y of the tile.

		// Getting tiles count.
		var tiles_count = array_length(self.tiles);
		
		for (var tile_index = 0; tile_index < tiles_count; tile_index++){
			// Iterating over all tiles.
			
			// Getting position.
			var position = self.tiles[tile_index];

			if (position[0] == remove_x and position[1] == remove_y){
				// If correct position.
				
				// Deleting tile.
				array_delete(self.tiles, tile_index, 1);
				
				// Returning.
				return;
			}
		}
		
		// Recalculating edges.
		self.calculate_edges();
	}

}