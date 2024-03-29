#ifndef __RENDERLIST_H
#define __RENDERLIST_H

#include <list>
#include <algorithm>
#include <memory>
#include <SDL2/SDL.h>

/**
 * Renderable interface.
 * \brief Anything that can be rendered, implements this interface.
 */
class Renderable
{
	int order;
	public:

	Renderable() : order(0)
	{}

	virtual ~Renderable() = default;

	virtual void render(const SDL_Renderer* renderer) = 0;

	virtual bool shouldRender() { return false; }

	inline void setOrder( int newOrder )
	{
		order = newOrder;
	}

	inline int getOrder() {
		return order;
	}

	// For sorting.
	inline bool operator< ( const Renderable& rhs ) const
	{
		return order < rhs.order;
	}
	
	// For removing.
	inline bool operator== ( const Renderable& rhs ) const
	{
		return this == &rhs;
	}
};

using RenderablePtr = std::shared_ptr<Renderable>;

/**
 * \brief List of renderables to render.
 */
class RenderList : public Renderable
{
	std::list<RenderablePtr> list;
	bool flagShouldRender;

	public:
	RenderList() : flagShouldRender(false) {}
	virtual ~RenderList() { SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, "~RenderList %lx\n", (unsigned long)this); }

	inline void sort()
	{
		list.sort(
			[](const RenderablePtr &lhs, const RenderablePtr &rhs)
			{ return lhs->getOrder() < rhs->getOrder(); });
	}
	
	// Adds item according to it's sort order.
	inline void insert( RenderablePtr&& item )
	{
		list.emplace_back( std::move( item ) );
		sort();
	}

	inline void remove( const RenderablePtr& item )
	{
		list.remove( item );
	}

	inline void clear()
	{
		list.clear();
	}

	// Adds item at the end and adjusts it's sort order
	inline void add( RenderablePtr&& item )
	{
		if ( list.empty() ) {
			item->setOrder( 100 ); // Allow for inserting infront.
			list.emplace_back( std::move( item ) );
			return;
		}

		int maxOrder = list.back()->getOrder();

		maxOrder++;

		item->setOrder( maxOrder );

		list.emplace_back( std::move( item ) );
	}

	inline void render(const SDL_Renderer* renderer)
	{
		for ( auto& item : list )
		{
			item->render(renderer);
		}
		flagShouldRender = false;
	}

	inline bool shouldRender()
	{
		if (flagShouldRender)
		{
			return true;
		}

		for ( auto& item: list)
		{
			if (item->shouldRender())
			{
				return true;
			}
		}
		return false;
	}

	inline void setShouldRender(bool flag)
	{
		flagShouldRender = flag;
	}
};

using RenderListPtr = std::shared_ptr<RenderList>;

#endif // __RENDERLIST_H
