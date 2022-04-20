package wren

import "core:os"

when ODIN_OS == .Linux {
    foreign import lib "libwren.a"
} else {
    #assert(false)
}

// Constants
VERSION_MAJOR :: 0
VERSION_MINOR :: 4
VERSION_PATCH :: 0

VERSION_STRING :: "0.4.0"
VERSION_NUMBER :: VERSION_MAJOR * 1000000 +
    VERSION_MINOR * 1000 +
    VERSION_PATCH

// Opaque struct pointers
VM :: distinct rawptr
Handle :: distinct rawptr

// Enums
ErrorType :: enum {
    COMPILE,
    RUNTIME,
    STACK_TRACE,
}

InterpretResult :: enum {
    SUCCESS,
    COMPILE_ERROR,
    RUNTIME_ERROR,
}

Type :: enum {
    BOOL,
    NUM,
    FOREIGN,
    LIST,
    MAP,
    NULL,
    STRING,
    UNKNOWN,
}

// Structs
LoadModuleResult :: struct {
    source: cstring,
    onComplete: LoadModuleCompleteFn,
    userData: rawptr,
}

ForeignClassMethods :: struct {
    allocate: ForeignMethodFn,
    finalize: FinalizerFn,
}

Configuration :: struct {
    reallocateFn: ReallocateFn,
    resolveModuleFn: ResolveModuleFn,
    loadModuleFn: LoadModuleFn,
    bindForeignMethodFn: BindForeignMethodFn,
    bindForeignClassFn: BindForeignClassFn,
    writeFn: WriteFn,
    errorFn: ErrorFn,
    initialHeapSize: uint,
    minHeapSize: uint,
    heapGrowthPercent: i32,
    userData: rawptr,
}

// Proc types
ReallocateFn :: #type proc "c" (memory: rawptr, newSize: uint, userData: rawptr) -> rawptr
ForeignMethodFn :: #type proc "c" (vm: VM)
FinalizerFn :: #type proc "c" (data: rawptr)
ResolveModuleFn :: #type proc "c" (vm: VM, importer: cstring, name: cstring) -> cstring
LoadModuleCompleteFn :: #type proc "c" (vm: VM, name: cstring, result: LoadModuleResult)
LoadModuleFn :: #type proc "c" (vm: VM, name: cstring) -> LoadModuleResult
BindForeignMethodFn :: #type proc "c" (vm: VM, module: cstring, className: cstring, isStatic: bool, signature: cstring) -> ForeignMethodFn
BindForeignClassFn :: #type proc "c" (vm: VM, module: cstring, className: cstring) -> ForeignClassMethods
WriteFn :: #type proc "c" (vm: VM, text: cstring)
ErrorFn :: #type proc "c" (vm: VM, type: ErrorType, module: cstring, line: i32, message: cstring)

@(link_prefix = "wren")
foreign lib {
    GetVersionNumber :: proc() -> i32 ---
    InitConfiguration :: proc(configuration: ^Configuration) ---
    NewVM :: proc(configuration: ^Configuration) -> VM ---
    FreeVM :: proc(vm: VM) ---
    CollectGarbage :: proc(vm: VM) ---
    Interpret :: proc(vm: VM, module: cstring, source: cstring) -> InterpretResult ---
    MakeCallHandle :: proc(vm: VM, signature: cstring) -> Handle ---
    Call :: proc(vm: VM, method: Handle) -> InterpretResult ---
    ReleaseHandle :: proc(vm: VM, handle: Handle) ---
    GetSlotCount :: proc(vm: VM) -> i32 ---
    EnsureSlots :: proc(vm: VM, numSlots: i32) ---
    GetSlotType :: proc(vm: VM, slot: i32) -> Type ---
    GetSlotBool :: proc(vm: VM, slot: i32) -> bool ---
    GetSlotBytes :: proc(vm: VM, slot: i32, length: ^i32) -> cstring ---
    GetSlotDouble :: proc(vm: VM, slot: i32) -> f64 ---
    GetSlotForeign :: proc(vm: VM, slot: i32) -> rawptr ---
    GetSlotString :: proc(vm: VM, slot: i32) -> cstring ---
    GetSlotHandle :: proc(vm: VM, slot: i32) -> Handle ---
    SetSlotBool :: proc(vm: VM, slot: i32, value: bool) ---
    SetSlotBytes :: proc(vm: VM, slot: i32, bytes: cstring, length: uint) ---
    SetSlotDouble :: proc(vm: VM, slot: i32, value: f64) ---
    SetSlotNewForeign :: proc(vm: VM, slot: i32, classSlot: i32, size: uint) -> rawptr ---
    SetSlotNewList :: proc(vm: VM, slot: i32) ---
    SetSlotNewMap :: proc(vm: VM, slot: i32) ---
    SetSlotNull :: proc(vm: VM, slot: i32) ---
    SetSlotString :: proc(vm: VM, slot: i32, text: cstring) ---
    SetSlotHandle :: proc(vm: VM, slot: i32, handle: Handle) ---
    GetListCount :: proc(vm: VM, slot: i32) -> i32 ---
    GetListElement :: proc(vm: VM, listSlot: i32, index: i32, elementSlot: i32) ---
    SetListElement :: proc(vm: VM, listSlot: i32, index: i32, elementSlot: i32) ---
    InsertInList :: proc(vm: VM, listSlot: i32, index: i32, elementSlot: i32) ---
    GetMapCount :: proc(vm: VM, slot: i32) -> i32 ---
    GetMapContainsKey :: proc(vm: VM, mapSlot: i32, keySlot: i32) -> bool ---
    GetMapValue :: proc(vm: VM, mapSlot: i32, keySlot: i32, valueSlot: i32) ---
    SetMapValue :: proc(vm: VM, mapSlot: i32, keySlot: i32, valueSlot: i32) ---
    RemoveMapValue :: proc(vm: VM, mapSlot: i32, keySlot: i32, removedValueSlot: i32) ---
    GetVariable :: proc(vm: VM, module: cstring, name: cstring, slot: i32) ---
    HasVariable :: proc(vm: VM, module: cstring, name: cstring, slot: i32) -> bool ---
    HasModule :: proc(vm: VM, module: cstring) -> bool ---
    AbortFiber :: proc(vm: VM, slot: i32) ---
    GetUserData :: proc(vm: VM) -> rawptr ---
    SetUserData :: proc(vm: VM, userData: rawptr) ---
}
