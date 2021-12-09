/// @description Tile type enumeration.
// @author Kirill Zhosul (@kirillzhosul)

enum eTILE_TYPE{
	// Tile type enumeration.
	// Used in `tile` structure type field.
	
	// Biomes.
	FOREST,
	DESERT,
	// Cities.
	CITY,
	// Water.
	WATER,
	
	// Used for check enum bounds.
	// By default, this value has size of enumeration.
	COUNT
}