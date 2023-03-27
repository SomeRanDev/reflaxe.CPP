// =======================================================
// * UMeta
//
// Adds static extensions for reflaxe.helpers.NameMetaHelper.NameAndMeta.
// Aka. objects that match: { name: String, meta: Null<MetaAccess> }
// =======================================================

package unboundcompiler.helpers;

#if (macro || ucpp_runtime)

using reflaxe.helpers.NameMetaHelper;

enum MemoryManagementType {
	Value;
	UnsafePtr;
	SharedPtr;
	UniquePtr;
}

class UMeta {
	public static function hasNativeMeta(meta: NameAndMeta): Bool {
		return meta.hasMeta(":native");
	}

	public static function isHeaderOnly(meta: NameAndMeta): Bool {
		return meta.hasMeta(":headerOnly");
	}

	public static function isArrowAccess(meta: NameAndMeta): Bool {
		return meta.hasMeta(":arrowAccess");
	}

	public static function isOverrideMemoryManagement(meta: NameAndMeta): Bool {
		return meta.hasMeta(":overrideMemoryManagement");
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta.
	public static function getMemoryManagementType(meta: NameAndMeta): MemoryManagementType {
		return if(meta.hasMeta(":valueType")) {
			Value;
		} else if(meta.hasMeta(":unsafePtrType")) {
			UnsafePtr;
		} else if(meta.hasMeta(":uniquePtrType")) {
			UniquePtr;
		} else {
			SharedPtr;
		}
	}

	public static function hasMemoryManagementType(meta: NameAndMeta): Bool {
		return meta.hasMeta(":valueType") || meta.hasMeta(":unsafePtrType") || meta.hasMeta(":uniquePtrType") || meta.hasMeta(":sharedPtrType");
	}
}

#end
