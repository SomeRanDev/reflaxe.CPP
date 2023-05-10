#pragma once

#include <any>
#include <deque>
#include <exception>
#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_CallStack.h"

namespace haxe {

class Exception: public std::exception {
public:
	std::string _message;
	
	std::optional<std::shared_ptr<haxe::Exception>> _previous;

	Exception(std::string message, std::optional<haxe::Exception> previous = std::nullopt, std::optional<std::any> native = std::nullopt);
	
	std::string get_message();
	
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> get_stack();
	
	std::optional<haxe::Exception> get_previous();
	
	std::any get_native();
	
	std::any unwrap();
	
	virtual std::string toString();
	
	std::string details();
	
	static haxe::Exception caught(std::any value);
	
	static std::any thrown(std::any value);
	
	HX_COMPARISON_OPERATORS(Exception)
};

}
