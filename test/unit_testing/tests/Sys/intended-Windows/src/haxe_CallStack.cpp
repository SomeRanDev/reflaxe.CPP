#include "haxe_CallStack.h"

#include <deque>
#include <memory>
#include <string>
#include "HxArray.h"
#include "HxString.h"
#include "Std.h"
#include "StringBuf.h"

using namespace std::string_literals;

std::string haxe::_CallStack::CallStack_Impl_::toString(std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> stack) {
	std::shared_ptr<StringBuf> b = std::make_shared<StringBuf>();
	int _g = 0;
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> _g1 = stack;

	while(_g < (int)(_g1->size())) {
		std::shared_ptr<haxe::StackItem> s = (*_g1)[_g];

		++_g;
		b->b += Std::string("\nCalled from "s);
		haxe::_CallStack::CallStack_Impl_::itemToString(b, s);
	};

	return b->b;
}

void haxe::_CallStack::CallStack_Impl_::itemToString(std::shared_ptr<StringBuf> b, std::shared_ptr<haxe::StackItem> s) {
	switch(s->index) {
		case 0: {
			b->b += Std::string("a C function"s);
			break;
		}
		case 1: {
			std::string _g = s->getModule().m;
			std::string m = _g;

			b->b += Std::string("module "s);
			b->b += Std::string(m);
			break;
		}
		case 2: {
			std::optional<std::shared_ptr<haxe::StackItem>> _g = s->getFilePos().s;
			std::string _g1 = s->getFilePos().file;
			int _g2 = s->getFilePos().line;
			std::optional<int> _g3 = s->getFilePos().column;
			std::optional<std::shared_ptr<haxe::StackItem>> s2 = _g;
			std::string file = _g1;
			int line = _g2;
			std::optional<int> col = _g3;

			if(s2.has_value()) {
				haxe::_CallStack::CallStack_Impl_::itemToString(b, s2.value_or(nullptr));
				b->b += Std::string(" ("s);
			};

			b->b += Std::string(file);
			b->b += Std::string(" line "s);
			b->b += Std::string(line);

			if(col.has_value()) {
				b->b += Std::string(" column "s);
				b->b += Std::string(col);
			};
			if(s2.has_value()) {
				b->b += Std::string(")"s);
			};
			break;
		}
		case 3: {
			std::optional<std::string> _g = s->getMethod().classname;
			std::string _g1 = s->getMethod().method;
			std::optional<std::string> cname = _g;
			std::string meth = _g1;
			std::optional<std::string> tempMaybeString;

			if(!cname.has_value()) {
				tempMaybeString = "<unknown>"s;
			} else {
				tempMaybeString = cname;
			};

			b->b += Std::string(tempMaybeString.value());
			b->b += Std::string("."s);
			b->b += Std::string(meth);
			break;
		}
		case 4: {
			std::optional<int> _g = s->getLocalFunction().v;
			std::optional<int> n = _g;

			b->b += Std::string("local function #"s);
			b->b += Std::string(n);
			break;
		}
		default: {}
	};
}
