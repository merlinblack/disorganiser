#ifndef __ATLAS_H
#define __ATLAS_H

#include <vector>
#include <memory>
#include "texture.h"

using ImageList = std::vector<SDL_Rect>;

class Atlas
{
	TexturePtr texture;
	ImageList list;
	float horizontalScale, verticalScale;

	public:

	Atlas() : texture(nullptr), horizontalScale(1.0), verticalScale(1.0) {}

	void setTexture(TexturePtr texture);
	std::size_t addImage(SDL_Rect& src);
	void setScale(float hScale, float vScale);
	size_t size() { return list.size(); }

	bool renderImage(const SDL_Renderer* renderer, std::size_t index, int x, int y );
};

using AtlasPtr = std::shared_ptr<Atlas>;

#endif // __ATLAS_H