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
	
	virtual ~Exception() {}

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


#include "dynamic/Dynamic_haxe_Exception.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::Exception> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_Exception;
		constexpr static _class_data<13, 2> data {
			"Exception",
			{ "message", "get_message", "stack", "get_stack", "previous", "get_previous", "native", "get_native", "_message", "_previous", "unwrap", "toString", "details" },
			{ "caught", "thrown" },
			true
			};
	};
}
