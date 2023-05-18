#include "haxe_Exception.h"

#include <memory>
#include <string>
#include "haxe_CallStack.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"

using namespace std::string_literals;

haxe::Exception::Exception(std::string message, std::optional<haxe::Exception> previous, std::optional<std::any> native):
	std::exception(), _order_id(generate_order_id())
{
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 50, 2, "haxe.Exception"s, "Exception"s);
	
	HCXX_LINE(51);
	HCXX_LINE(53);
	this->_message = message;
	
	HCXX_LINE(54);
	std::optional<std::shared_ptr<haxe::Exception>> tempRight;
	
	HCXX_LINE(54);
	if(previous.has_value()) {
		HCXX_LINE(54);
		tempRight = std::make_shared<haxe::Exception>(previous.value());
	} else {
		HCXX_LINE(54);
		tempRight = std::nullopt;
	};
	
	HCXX_LINE(54);
	this->_previous = tempRight;
	HCXX_LINE(56);
	this->_stack = haxe::NativeStackTrace::toHaxe(haxe::NativeStackTrace::callStack(), 0);
}

std::string haxe::Exception::get_message() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 8, 2, "haxe.Exception"s, "get_message"s);
	
	HCXX_LINE(9);
	return this->_message;
}

std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> haxe::Exception::get_stack() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 13, 2, "haxe.Exception"s, "get_stack"s);
	
	HCXX_LINE(15);
	return this->_stack;
}

std::optional<haxe::Exception> haxe::Exception::get_previous() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 23, 2, "haxe.Exception"s, "get_previous"s);
	
	auto v = this->_previous;
	HCXX_LINE(24);
	return v.has_value() ? (std::optional<haxe::Exception>)(*v.value()) : std::nullopt;
}

std::any haxe::Exception::get_native() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 28, 2, "haxe.Exception"s, "get_native"s);
	
	HCXX_LINE(29);
	return 0;
}

std::any haxe::Exception::unwrap() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 60, 2, "haxe.Exception"s, "unwrap"s);
	
	HCXX_LINE(61);
	return 0;
}

std::string haxe::Exception::toString() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 64, 2, "haxe.Exception"s, "toString"s);
	
	HCXX_LINE(65);
	return "Error: "s + this->get_message();
}

std::string haxe::Exception::details() {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 68, 2, "haxe.Exception"s, "details"s);
	
	HCXX_LINE(69);
	return this->toString() + "\n"s + haxe::_CallStack::CallStack_Impl_::toString(this->get_stack());
}

haxe::Exception haxe::Exception::caught(std::any value) {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 34, 2, "haxe.Exception"s, "caught"s);
	
	HCXX_LINE(35);
	std::string tempString = "<Any("s + Std::string(value.type().name()) + ")>"s;
	
	HCXX_LINE(35);
	return haxe::Exception(tempString, std::nullopt, std::nullopt);
}

std::any haxe::Exception::thrown(std::any value) {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Exception.hx"s, 38, 2, "haxe.Exception"s, "thrown"s);
	
	HCXX_LINE(39);
	return 0;
}
