#include "haxe_Exception.h"

#include <iostream>
#include <memory>
#include <string>
#include "haxe_CallStack.h"
#include "Std.h"

using namespace std::string_literals;

haxe::Exception::Exception(std::string message, std::optional<haxe::Exception> previous, std::optional<std::any> native):
	std::exception(), _order_id(generate_order_id())
{
	this->_message = message;
	
	std::optional<std::shared_ptr<haxe::Exception>> tempRight;
	
	if(previous.has_value()) {
		tempRight = std::make_shared<haxe::Exception>(previous.value());
	} else {
		tempRight = std::nullopt;
	};
	
	this->_previous = tempRight;
}

std::string haxe::Exception::get_message() {
	return this->_message;
}

std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> haxe::Exception::get_stack() {
	std::cout << Std::string("Call stack features must be enabled using -D cxx_callstack."s) << std::endl;
	
	return std::make_shared<std::deque<std::shared_ptr<haxe::StackItem>>>(std::deque<std::shared_ptr<haxe::StackItem>>{});
}

std::optional<haxe::Exception> haxe::Exception::get_previous() {
	auto v = this->_previous;
	return v.has_value() ? (std::optional<haxe::Exception>)(*v.value()) : std::nullopt;
}

std::any haxe::Exception::get_native() {
	return 0;
}

std::any haxe::Exception::unwrap() {
	return 0;
}

std::string haxe::Exception::toString() {
	return "Error: "s + this->get_message();
}

std::string haxe::Exception::details() {
	return this->toString() + "\n"s + haxe::_CallStack::CallStack_Impl_::toString(this->get_stack());
}

haxe::Exception haxe::Exception::caught(std::any value) {
	std::string tempString = "<Any("s + Std::string(value.type().name()) + ")>"s;
	
	return haxe::Exception(tempString, std::nullopt, std::nullopt);
}

std::any haxe::Exception::thrown(std::any value) {
	return 0;
}
