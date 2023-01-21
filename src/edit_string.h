#ifndef __EDIT_STRING_H
#define __EDIT_STRING_H

#include <memory>
#include <string>
#include <vector>
#include "utf8.h"

class EditString
{
	using UCSvector = std::vector<u_int32_t>;

	UCSvector codepoints;
	UCSvector::iterator cursor;

	public:
	EditString();
	std::string toString();
	void setString(const std::string& str);

	void gotoStart();
	void gotoEnd();
	void back();
	void forward();
	void backWord();
	void forwardWord();

	int getCharacaterIndex();

	void clear();
	void insert(const std::string& str);
	void erase();

};

using EditStringPtr = std::shared_ptr<EditString>;

#endif // __EDIT_STRING_H