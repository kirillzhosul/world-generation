/// @description Tile structure implementation
// @author Kirill Zhosul (@kirillzhosul)

function sTile(type) constructor{
	// Tile constructor.
	// Contains implementation of the tile structure.
	
	// Thinks:
	// There is a lot function declarations inside,
	// May be better to create something like model-presenter,
	// That will works with things based on structure values,
	// And then pass it back / do any action?.
	// I may wrong.
	
	
	// Pass given type to the type.
	// Type should be in range from 0 to eTILE_TYPE.COUNT
	// (Actually eTILE_TYPE).
	self._type = type;
	// !There is `set_type()` function call below!
	
	
	// Color by default.
	// Should be updaten when calling `_update_color()` which is called
	// When calling `set_type()`.
	//  If there is tile memory color opitimization enabled, we don`t initalise color value,
	//  As this setting should reduce memory usage.
	if not WORLD_TILE_COLOR_OPTIMIZATION self._color = undefined;
	
	
	// Type getter / setter.
	self.set_type = function(type){
		// @description Setter for type.
		// @param {eTILE_TYPE} type Value to set.
		
		// Setting.
		self._type = type;
		
		// Updating state.
		self._update_color();
	}
	self.get_type = function(){
		// @description Getter for type.
		// @returns {eTILE_TYPE} Value.
		
		// Returning.
		return self._type;
	}
	
	// Color getter.
	self.get_color = function(){
		// @description Getter for color.
		// @returns {real} Color.
		
		if WORLD_TILE_COLOR_OPTIMIZATION{
			// If there is tile memory color optimization enabled.
			
			// Returning not a tile color field value,
			// Returning color tile colors lookup-table.
			return array_get(WORLD_TILE_COLORS, self._type);
		}
		
		// Returning.
		return self._color;
	}
	self.mix_color = function(l, r, d, u){
		// @description Mixes color with given colors.
		// @param {sTile} l Left tile.
		// @param {sTile} r Right tile.
		// @param {sTile} d Down tile.
		// @param {sTile} u Up tile.
		
		// Getting current color HUE.
		var color_hue = color_get_hue(self.get_color());
		
		// Getting other tiles colors.
		// Steps: Check type of the tile, if it`s not our type, get color from tile,
		// Otherwise, get color from color_hue (Same with tile color but yes).
		l = l.get_type() != self._type ? color_get_hue(l.get_color()) : color_hue;
		r = r.get_type() != self._type ? color_get_hue(r.get_color()) : color_hue;
		d = d.get_type() != self._type ? color_get_hue(d.get_color()) : color_hue;
		u = u.get_type() != self._type ? color_get_hue(u.get_color()) : color_hue;
		
		// Getting differences.
		l = abs(l - color_hue);
		r = abs(r - color_hue);
		d = abs(d - color_hue);
		u  =abs(u - color_hue);
		
		// Getting selected color.
		var selected_color = floor(max(l, r, d, u) / WORLD_COLOR_MIXING_VALUE);
		
		// Create new color (Mixing, actually).
		var new_color =make_color_hsv(
			color_get_hue(self._color) + selected_color, 
			color_get_saturation(self._color) + selected_color, 
			color_get_value(self._color) + selected_color
		);
		
		// Setting.
		self._color = new_color;
	}
	self._update_color = function(){
		// @description [PRIVATE MEMBER] Updates color (Almost like private-setter).
		
		// Not processing color update,
		// If there is tile memory color optimization flag in the settings.
		if WORLD_TILE_COLOR_OPTIMIZATION return;
		
		// Getting default color from tile colors lookup-table by type.
		var color = array_get(WORLD_TILE_COLORS, self._type);
		
		// Updating color value.
		color = make_color_hsv(
			color_get_hue(color), 
			color_get_saturation(color), 
			color_get_value(color) + irandom_range(-6, 6)  // TODO: Add settings field for controlling that spreading.
		);
		
		// Setting.
		self._color = color;
	}
	
	// Sity getters / setter.
	self.set_city = function(city){
		// @description Setter for city.
		// @param {sCity} city Value.
		
		// Setting.
		variable_struct_set(self, "city", city);
	}
	self.try_get_city = function(){
		// @description Getter for city.
		// @returns {sCity or undefined}
		
		// Returning.
		return variable_struct_get(self, "CITY");
	}
	
	// Other functions.
	self.draw = function(x, y){
		// @description Draws tile.
		// @param {real} x X to draw at.
		// @param {real} y Y to draw at.
		
		// Setting color.
		draw_set_color(self.get_color());

		// Drawing rectangle with world tile size.
		draw_rectangle(x, y, x + WORLD_TILE_SIZE, y + WORLD_TILE_SIZE, false);
		
		if WORLD_TILE_FILTER_CIRCLE{
			// If there is circle filter enabled.
			
			// Drawing circle for creating circle-like-filter.
			draw_circle(x, y, WORLD_TILE_FILTER_CIRCLE, false);
		}
	}

	// Pass given type to type setter.
	// As there is some setter logic.
	// (Color updating).
	self.set_type(self._type);
}
