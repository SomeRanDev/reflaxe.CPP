#include "haxe_io_Bytes.h"

#include <deque>
#include <memory>
#include <string>

haxe::io::Bytes::Bytes(int length, std::shared_ptr<haxe::io::BytesData> b):
	_order_id(generate_order_id())
{
	this->length = length;
	this->b = b;
}

std::shared_ptr<haxe::io::Bytes> haxe::io::Bytes::ofString(std::string s, std::optional<std::shared_ptr<haxe::io::Encoding>> encoding) {
	std::shared_ptr<std::deque<int>> a = std::make_shared<std::deque<int>>();
	int i = 0;

	while(i < (int)(s.size())) {
		int tempNumber = 0;

		{
			int index = i++;

			if((index < 0) || (index >= (int)(s.size()))) {
				tempNumber = -1;
			} else {
				tempNumber = s.at(index);
			};
		};

		int c = tempNumber;

		if((55296 <= c) && (c <= 56319)) {
			int tempLeft = 0;

			{
				int index = i++;

				if((index < 0) || (index >= (int)(s.size()))) {
					tempLeft = -1;
				} else {
					tempLeft = s.at(index);
				};
			};

			c = (((c - 55232) << 10) | (tempLeft & 1023));
		};
		if(c <= 127) {
			a->push_back(c);
		} else if(c <= 2047) {
			a->push_back(192 | (c >> 6));
			a->push_back(128 | (c & 63));
		} else if(c <= 65535) {
			a->push_back(224 | (c >> 12));
			a->push_back(128 | ((c >> 6) & 63));
			a->push_back(128 | (c & 63));
		} else {
			a->push_back(240 | (c >> 18));
			a->push_back(128 | ((c >> 12) & 63));
			a->push_back(128 | ((c >> 6) & 63));
			a->push_back(128 | (c & 63));
		};
	};

	return std::make_shared<haxe::io::Bytes>((int)(a->size()), a);
}
