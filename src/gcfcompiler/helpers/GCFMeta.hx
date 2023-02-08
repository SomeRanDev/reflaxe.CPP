package gcfcompiler.helpers;

#if (macro || gcf_runtime)

using reflaxe.helpers.NameMetaHelper;

enum MemoryManagementType {
	Value;
	UnsafePtr;
	SharedPtr;
	UniquePtr;
}

class GCFMeta {
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
		} else if(meta.hasMeta(":rawPtrType")) {
			UnsafePtr;
		} else if(meta.hasMeta(":uniquePtrType")) {
			UniquePtr;
		} else {
			SharedPtr;
		}
	}
}

#end
