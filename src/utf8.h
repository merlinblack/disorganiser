#ifndef __UTF8_H
#define __UTF8_H

#include <vector>
#include <string>

std::vector<u_int32_t> utf8_to_ucs(const std::string& src);
std::string ucs_to_utf8(std::vector<u_int32_t> src);

#endif // __UTF8_H