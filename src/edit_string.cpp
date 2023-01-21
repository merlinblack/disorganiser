#include "edit_string.h"

EditString::EditString()
{
	cursor = codepoints.begin();
}

std::string EditString::toString()
{
	return ucs_to_utf8(codepoints);
}

void EditString::setString(const std::string& str)
{
	codepoints = utf8_to_ucs(str);
	cursor = codepoints.end();
}

void EditString::gotoStart()
{
	cursor = codepoints.begin();
}

void EditString::gotoEnd()
{
	cursor = codepoints.end();
}

void EditString::back()
{
	if (cursor != codepoints.begin())
		cursor--;
}

void EditString::forward()
{
	if (cursor != codepoints.end())
		cursor++;
}

void EditString::backWord()
{
	back();

	while(*cursor != 32 && cursor != codepoints.begin())
		back();
}

void EditString::forwardWord()
{
	forward();

	while(*cursor != 32 && cursor != codepoints.end())
		forward();
}

int EditString::getCharacaterIndex()
{
	return cursor - codepoints.begin();
}

void EditString::clear()
{
	codepoints.clear();
	cursor = codepoints.begin();
}

void EditString::insert(const std::string& str)
{
	UCSvector newpoints = utf8_to_ucs(str);

	for(const auto& point : newpoints)
	{
		cursor = codepoints.insert(cursor, point);
		cursor++;
	}
}

void EditString::erase()
{
	if (cursor != codepoints.end())
	{
		cursor = codepoints.erase(cursor);
	}
}
