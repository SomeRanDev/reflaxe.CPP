// =======================================================
// * MetaHelper
//
// Adds static extensions for objects that match:
//    { name: String, meta: Null<MetaAccess> }
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

import cxxcompiler.config.Meta;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.Error;

/**
	An enum for memory management types.
**/
enum MemoryManagementType {
	Value;
	UnsafePtr;
	SharedPtr;
	UniquePtr;
}

/**
	Adds static extensions for objects that match:
	`{ name: String, meta: Null<MetaAccess> }`
**/
class MetaHelper {
	public static function hasNativeMeta(meta: NameAndMeta): Bool {
		return meta.hasMeta(":native");
	}

	public static function isHeaderOnly(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.HeaderOnly);
	}

	public static function isArrowAccess(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.ArrowAccess);
	}

	public static function metaIsOverrideMemoryManagement(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.OverrideMemoryManagement);
	}

	public static function getCombinedStringContentOfMeta(meta: NameAndMeta, metaName: String): String {
		return meta.meta.extractPrimtiveFromAllMeta(metaName, 0).join("");
	}

	/**
		Returns the memory manage type based on the meta.
	**/
	public static function getMemoryManagementType(meta: NameAndMeta): MemoryManagementType {
		return if(meta.hasMeta(Meta.ValueType)) {
			Value;
		} else if(meta.hasMeta(Meta.UnsafePtrType)) {
			UnsafePtr;
		} else if(meta.hasMeta(ValueType.UniquePtrType)) {
			UniquePtr;
		} else if(meta.hasMeta(Meta.SharedPtrType)) {
			SharedPtr;
		} else {
			#if cxx_smart_ptr_disabled
			Value;
			#else
			SharedPtr;
			#end
		}
	}

	public static function hasMemoryManagementType(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.ValueType) || meta.hasMeta(Meta.UnsafePtrType) || meta.hasMeta(ValueType.UniquePtrType) || meta.hasMeta(ValueType.SharedPtrType);
	}

	public static function applyPassConstTypeParam(type: Type, meta: Array<MetadataEntry>, pos: Position) {
		final params = type.getParams() ?? [];
		final exprReplaceMap: Map<Int, haxe.macro.Expr> = [];
		for(entry in meta) {
			final metaArgs = entry.params;
			if(metaArgs == null || metaArgs.length < 2) {
				entry.pos.makeError(ErrorType.InvalidPassConstTypeParam);
				return;
			}
			final index: Int = switch(metaArgs[1].expr) {
				case EConst(CInt(v, _)): Std.parseInt(v) ?? -1;
				case _: {
					entry.pos.makeError(ErrorType.InvalidPassConstTypeParamIndex);
					return;
				}
			}
			if(index < 0 || index >= params.length) {
				entry.pos.makeError(ErrorType.PassConstTypeParamIndexOutsideRange);
			}
			if(exprReplaceMap.exists(index)) {
				entry.pos.makeError(ErrorType.DuplicatePassConstTypeParam);
			}
			exprReplaceMap.set(index, metaArgs[0]);
		}

		for(i in exprReplaceMap.keys()) {
			if(i < 0 || i >= params.length) throw "Impossible";
			switch(params[i]) {
				case TInst(_.get() => { kind: KExpr(_), meta: meta }, _) : {
					final expr = exprReplaceMap.get(i);
					if(expr != null) {
						meta.add(Meta.OverwriteKExpr, [expr], pos);
					}
				}
				case _:
			}
		};
	}
}

#end
