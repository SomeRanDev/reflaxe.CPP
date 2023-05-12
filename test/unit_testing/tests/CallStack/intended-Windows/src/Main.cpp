#include "Main.h"

#include <cstdlib>
#include <deque>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_CallStack.h"
#include "haxe_Log.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"

using namespace std::string_literals;

void _Main::Main_Fields_::assert(bool b) {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 3, 1, "Main_Fields_"s, "assert"s);
	
	HCXX_LINE(4);
	if(!b) {
		HCXX_LINE(5);
		HCXX_LINE(5);
		std::cout << Std::string("Failed"s) << std::endl;
		HCXX_LINE(6);
		exit(1);
	};
}

void _Main::Main_Fields_::main() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 10, 1, "Main_Fields_"s, "main"s);
	
	HCXX_LINE(11);
	_Main::Main_Fields_::test1();
}

void _Main::Main_Fields_::test1() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 14, 1, "Main_Fields_"s, "test1"s);
	
	HCXX_LINE(15);
	_Main::Main_Fields_::test2();
}

void _Main::Main_Fields_::test2() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 18, 1, "Main_Fields_"s, "test2"s);
	
	HCXX_LINE(19);
	_Main::Main_Fields_::test3();
}

void _Main::Main_Fields_::test3() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 22, 1, "Main_Fields_"s, "test3"s);
	
	HCXX_LINE(23);
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> callstack = haxe::_CallStack::CallStack_Impl_::callStack();
	
	HCXX_LINE(26);
	haxe::Log::trace(callstack, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/CallStack/Main.hx"s, 26, "test3"s));
	
	HCXX_LINE(28);
	{
		HCXX_LINE(28);
		std::shared_ptr<haxe::StackItem> _g = (*callstack)[0];
		
		HCXX_LINE(28);
		if(_g->index == 2) {
			HCXX_LINE(29);
			std::optional<std::shared_ptr<haxe::StackItem>> _g1 = _g->getFilePos().s;
			HCXX_LINE(29);
			HCXX_LINE(29);
			int _g3 = _g->getFilePos().line;
			HCXX_LINE(29);
			std::optional<int> _g4 = _g->getFilePos().column;
			
			HCXX_LINE(29);
			if(!_g1.has_value()) {
				HCXX_LINE(30);
				_Main::Main_Fields_::assert(false);
			} else if(_g1.value()->index == 3) {
				HCXX_LINE(29);
				std::optional<std::string> _g5 = _g1.value()->getMethod().classname;
				HCXX_LINE(29);
				std::string _g6 = _g1.value()->getMethod().method;
				
				HCXX_LINE(29);
				if(!_g5.has_value()) {
					HCXX_LINE(30);
					_Main::Main_Fields_::assert(false);
				} else if(_g5 == "Main_Fields_"s) {
					HCXX_LINE(29);
					if(_g6 == "test1"s) {
						HCXX_LINE(29);
						if(_g3 == 15) {
							HCXX_LINE(29);
							if(!_g4.has_value()) {
								HCXX_LINE(30);
								_Main::Main_Fields_::assert(false);
							} else if(_g4 == 1) {
								HCXX_LINE(29);
								_Main::Main_Fields_::assert(true);
							} else {
								HCXX_LINE(30);
								_Main::Main_Fields_::assert(false);
							};
						} else {
							HCXX_LINE(30);
							_Main::Main_Fields_::assert(false);
						};
					} else {
						HCXX_LINE(30);
						_Main::Main_Fields_::assert(false);
					};
				} else {
					HCXX_LINE(30);
					_Main::Main_Fields_::assert(false);
				};
			} else {
				HCXX_LINE(30);
				_Main::Main_Fields_::assert(false);
			};
		} else {
			HCXX_LINE(30);
			_Main::Main_Fields_::assert(false);
		};
	};
	HCXX_LINE(33);
	{
		HCXX_LINE(33);
		std::shared_ptr<haxe::StackItem> _g = (*callstack)[1];
		
		HCXX_LINE(33);
		if(_g->index == 2) {
			HCXX_LINE(34);
			std::optional<std::shared_ptr<haxe::StackItem>> _g1 = _g->getFilePos().s;
			HCXX_LINE(34);
			HCXX_LINE(34);
			int _g3 = _g->getFilePos().line;
			HCXX_LINE(34);
			std::optional<int> _g4 = _g->getFilePos().column;
			
			HCXX_LINE(34);
			if(!_g1.has_value()) {
				HCXX_LINE(35);
				_Main::Main_Fields_::assert(false);
			} else if(_g1.value()->index == 3) {
				HCXX_LINE(34);
				std::optional<std::string> _g5 = _g1.value()->getMethod().classname;
				HCXX_LINE(34);
				std::string _g6 = _g1.value()->getMethod().method;
				
				HCXX_LINE(34);
				if(!_g5.has_value()) {
					HCXX_LINE(35);
					_Main::Main_Fields_::assert(false);
				} else if(_g5 == "Main_Fields_"s) {
					HCXX_LINE(34);
					if(_g6 == "test2"s) {
						HCXX_LINE(34);
						if(_g3 == 19) {
							HCXX_LINE(34);
							if(!_g4.has_value()) {
								HCXX_LINE(35);
								_Main::Main_Fields_::assert(false);
							} else if(_g4 == 1) {
								HCXX_LINE(34);
								_Main::Main_Fields_::assert(true);
							} else {
								HCXX_LINE(35);
								_Main::Main_Fields_::assert(false);
							};
						} else {
							HCXX_LINE(35);
							_Main::Main_Fields_::assert(false);
						};
					} else {
						HCXX_LINE(35);
						_Main::Main_Fields_::assert(false);
					};
				} else {
					HCXX_LINE(35);
					_Main::Main_Fields_::assert(false);
				};
			} else {
				HCXX_LINE(35);
				_Main::Main_Fields_::assert(false);
			};
		} else {
			HCXX_LINE(35);
			_Main::Main_Fields_::assert(false);
		};
	};
	HCXX_LINE(38);
	{
		HCXX_LINE(38);
		std::shared_ptr<haxe::StackItem> _g = (*callstack)[2];
		
		HCXX_LINE(38);
		if(_g->index == 2) {
			HCXX_LINE(39);
			std::optional<std::shared_ptr<haxe::StackItem>> _g1 = _g->getFilePos().s;
			HCXX_LINE(39);
			HCXX_LINE(39);
			int _g3 = _g->getFilePos().line;
			HCXX_LINE(39);
			std::optional<int> _g4 = _g->getFilePos().column;
			
			HCXX_LINE(39);
			if(!_g1.has_value()) {
				HCXX_LINE(40);
				_Main::Main_Fields_::assert(false);
			} else if(_g1.value()->index == 3) {
				HCXX_LINE(39);
				std::optional<std::string> _g5 = _g1.value()->getMethod().classname;
				HCXX_LINE(39);
				std::string _g6 = _g1.value()->getMethod().method;
				
				HCXX_LINE(39);
				if(!_g5.has_value()) {
					HCXX_LINE(40);
					_Main::Main_Fields_::assert(false);
				} else if(_g5 == "Main_Fields_"s) {
					HCXX_LINE(39);
					if(_g6 == "test3"s) {
						HCXX_LINE(39);
						if(_g3 == 23) {
							HCXX_LINE(39);
							if(!_g4.has_value()) {
								HCXX_LINE(40);
								_Main::Main_Fields_::assert(false);
							} else if(_g4 == 1) {
								HCXX_LINE(39);
								_Main::Main_Fields_::assert(true);
							} else {
								HCXX_LINE(40);
								_Main::Main_Fields_::assert(false);
							};
						} else {
							HCXX_LINE(40);
							_Main::Main_Fields_::assert(false);
						};
					} else {
						HCXX_LINE(40);
						_Main::Main_Fields_::assert(false);
					};
				} else {
					HCXX_LINE(40);
					_Main::Main_Fields_::assert(false);
				};
			} else {
				HCXX_LINE(40);
				_Main::Main_Fields_::assert(false);
			};
		} else {
			HCXX_LINE(40);
			_Main::Main_Fields_::assert(false);
		};
	};
}
