// =======================================================
// * Meta
//
// List all the custom metadata used in this project and
// provides access using a String enum abstract.
//
// Furthermore, it adds static extensions for objects that
// match: { name: String, meta: Null<MetaAccess> }
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import cxxcompiler.config.Meta;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;

// An enum for memory management types.
enum MemoryManagementType {
	Value;
	UnsafePtr;
	SharedPtr;
	UniquePtr;
}

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

	public static function isOverrideMemoryManagement(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.OverrideMemoryManagement);
	}

	public static function getCombinedStringContentOfMeta(meta: NameAndMeta, metaName: String): String {
		return meta.meta.extractPrimtiveFromAllMeta(metaName, 0).join("");
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta.
	public static function getMemoryManagementType(meta: NameAndMeta): MemoryManagementType {
		return if(meta.hasMeta(Meta.ValueType)) {
			Value;
		} else if(meta.hasMeta(Meta.UnsafePtrType)) {
			UnsafePtr;
		} else if(meta.hasMeta(ValueType.UniquePtrType)) {
			UniquePtr;
		} else {
			SharedPtr;
		}
	}

	public static function hasMemoryManagementType(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.ValueType) || meta.hasMeta(Meta.UnsafePtrType) || meta.hasMeta(ValueType.UniquePtrType) || meta.hasMeta(ValueType.SharedPtrType);
	}
}

#end
