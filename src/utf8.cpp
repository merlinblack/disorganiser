#include "utf8.h"

/*
	Based on two C functions from:

	Basic UTF-8 manipulation routines
	by Jeff Bezanson
	placed in the public domain Fall 2005

	https://www.cprogramming.com/tutorial/unicode.html
*/

using UCSchar = u_int32_t;
using UCSvector = std::vector<UCSchar>;

static const UCSchar offsetsFromUTF8[6] = {
	0x00000000UL, 0x00003080UL, 0x000E2080UL,
	0x03C82080UL, 0xFA082080UL, 0x82082080UL
};

static const char trailingBytesForUTF8[256] = {
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
};

UCSvector utf8_to_ucs(const std::string& src)
{
	UCSvector dest;
	UCSchar ch;
	int nb;

	

	// Rough guess at how much space we need. Might be less.
	dest.reserve(src.length());

	auto i = src.begin();

	while (i != src.end())
	{
		nb = trailingBytesForUTF8[(unsigned char)*i];
		ch = 0;
		switch (nb)
		{
			/* these fall through deliberately */
			case 3: ch += (unsigned char)*i++; ch <<= 6;
			case 2: ch += (unsigned char)*i++; ch <<= 6;
			case 1: ch += (unsigned char)*i++; ch <<= 6;
			case 0: ch += (unsigned char)*i++;
		}
		ch -= offsetsFromUTF8[nb];
		dest.push_back(ch);
	}
	return dest;
}

std::string ucs_to_utf8(UCSvector src)
{
	UCSchar ch;
	std::string dest;
	auto i = src.begin();

	// Rough guess how log the string will be.
	dest.reserve(src.size()*2);

	while (i != src.end())
	{
		ch = *i;
		if (ch < 0x80) {
			dest.push_back((char)ch);
		}
		else if (ch < 0x800) {
			dest.push_back((ch>>6) | 0xC0);
			dest.push_back((ch & 0x3F) | 0x80);
		}
		else if (ch < 0x10000) {
			dest.push_back((ch>>12) | 0xE0);
			dest.push_back(((ch>>6) & 0x3F) | 0x80);
			dest.push_back((ch & 0x3F) | 0x80);
		}
		else if (ch < 0x110000) {
			dest.push_back((ch>>18) | 0xF0);
			dest.push_back(((ch>>12) & 0x3F) | 0x80);
			dest.push_back(((ch>>6) & 0x3F) | 0x80);
			dest.push_back((ch & 0x3F) | 0x80);
		}
		i++;
	}

	// client code may want to do:
	// dest.shrink_to_fit();

	return dest;
}
