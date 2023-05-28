#include <xamarin/xamarin.h>
#include "registrar.h"
extern "C" {
static void native_to_managed_trampoline_1 (id self, SEL _cmd, MonoMethod **managed_method_ptr, id p0, uint32_t token_ref)
{
	NSObject *nsobj0 = NULL;
	MonoObject *mobj0 = NULL;
	int32_t created0 = false;
	MonoType *paramtype0 = NULL;
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [1];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	MonoObject *mthis = NULL;
	if (self) {
		mthis = xamarin_get_managed_object_for_ptr_fast (self, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	}
	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	xamarin_check_for_gced_object (mthis, _cmd, self, managed_method, &exception_gchandle);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	nsobj0 = (NSObject *) p0;
	if (nsobj0) {
		paramtype0 = xamarin_get_parameter_type (managed_method, 0);
		mobj0 = xamarin_get_nsobject_with_type_for_ptr_created (nsobj0, false, paramtype0, &created0, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) {
			exception_gchandle = xamarin_get_exception_for_parameter (8029, exception_gchandle, "Unable to marshal the parameter", _cmd, managed_method, paramtype0, 0, true);
			goto exception_handling;
		}
	}
	arg_ptrs [0] = mobj0;

	mono_runtime_invoke (managed_method, mthis, arg_ptrs, NULL);

exception_handling:
	xamarin_mono_object_release (&paramtype0);
	xamarin_mono_object_release (&mobj0);
	xamarin_mono_object_release (&mthis);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return;
}


static BOOL native_to_managed_trampoline_2 (id self, SEL _cmd, MonoMethod **managed_method_ptr, uint32_t token_ref)
{
	MonoObject *retval = NULL;
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	BOOL res = {0};
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [0];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	MonoObject *mthis = NULL;
	if (self) {
		mthis = xamarin_get_managed_object_for_ptr_fast (self, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	}
	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	xamarin_check_for_gced_object (mthis, _cmd, self, managed_method, &exception_gchandle);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	retval = mono_runtime_invoke (managed_method, mthis, arg_ptrs, NULL);

	res = *(BOOL *) mono_object_unbox ((MonoObject *) retval);

exception_handling:
	xamarin_mono_object_release (&retval);
	xamarin_mono_object_release (&mthis);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return res;
}


static id native_to_managed_trampoline_3 (id self, SEL _cmd, MonoMethod **managed_method_ptr, bool* call_super, uint32_t token_ref)
{
	MonoClass *declaring_type = NULL;
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [0];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	MonoObject *mthis = NULL;
	bool has_nsobject = xamarin_has_nsobject (self, &exception_gchandle);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	if (has_nsobject) {
		*call_super = true;
		goto exception_handling;
	}
	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	declaring_type = mono_method_get_class (managed_method);
	mthis = xamarin_new_nsobject (self, declaring_type, &exception_gchandle);
	xamarin_mono_object_release (&declaring_type);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	mono_runtime_invoke (managed_method, mthis, arg_ptrs, NULL);

exception_handling:
	xamarin_mono_object_release (&mthis);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return self;
}


static void native_to_managed_trampoline_4 (id self, SEL _cmd, MonoMethod **managed_method_ptr, uint32_t token_ref)
{
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [0];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	MonoObject *mthis = NULL;
	if (self) {
		mthis = xamarin_get_managed_object_for_ptr_fast (self, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	}
	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	xamarin_check_for_gced_object (mthis, _cmd, self, managed_method, &exception_gchandle);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	mono_runtime_invoke (managed_method, mthis, arg_ptrs, NULL);

exception_handling:
	xamarin_mono_object_release (&mthis);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return;
}


static void native_to_managed_trampoline_5 (id self, SEL _cmd, MonoMethod **managed_method_ptr, id p0, uint32_t token_ref)
{
	NSObject *nsobj0 = NULL;
	MonoObject *mobj0 = NULL;
	int32_t created0 = false;
	MonoType *paramtype0 = NULL;
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [1];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	nsobj0 = (NSObject *) p0;
	if (nsobj0) {
		paramtype0 = xamarin_get_parameter_type (managed_method, 0);
		mobj0 = xamarin_get_nsobject_with_type_for_ptr_created (nsobj0, false, paramtype0, &created0, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) {
			exception_gchandle = xamarin_get_exception_for_parameter (8029, exception_gchandle, "Unable to marshal the parameter", _cmd, managed_method, paramtype0, 0, true);
			goto exception_handling;
		}
	}
	arg_ptrs [0] = mobj0;

	mono_runtime_invoke (managed_method, NULL, arg_ptrs, NULL);

exception_handling:
	xamarin_mono_object_release (&paramtype0);
	xamarin_mono_object_release (&mobj0);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return;
}


static id native_to_managed_trampoline_6 (id self, SEL _cmd, MonoMethod **managed_method_ptr, uint32_t token_ref)
{
	MonoObject *retval = NULL;
	GCHandle exception_gchandle = INVALID_GCHANDLE;
	id res = {0};
	MonoMethod *managed_method = *managed_method_ptr;
	void *arg_ptrs [0];
	MonoReflectionMethod *reflection_method = NULL;
	MONO_ASSERT_GC_SAFE_OR_DETACHED;
	MONO_THREAD_ATTACH;

	MonoObject *mthis = NULL;
	if (self) {
		mthis = xamarin_get_managed_object_for_ptr_fast (self, &exception_gchandle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	}
	if (!managed_method) {
		GCHandle reflection_method_handle = xamarin_get_method_from_token (token_ref, &exception_gchandle);
		reflection_method = (MonoReflectionMethod *) xamarin_gchandle_unwrap (reflection_method_handle);
		if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
		managed_method = xamarin_get_reflection_method_method (reflection_method);
		*managed_method_ptr = managed_method;
		xamarin_mono_object_release_at_process_exit (managed_method);
	}
	xamarin_check_for_gced_object (mthis, _cmd, self, managed_method, &exception_gchandle);
	if (exception_gchandle != INVALID_GCHANDLE) goto exception_handling;
	retval = mono_runtime_invoke (managed_method, mthis, arg_ptrs, NULL);

	if (!retval) {
		res = NULL;
	} else {
		id retobj;
		retobj = xamarin_get_nsobject_handle (retval);
		xamarin_framework_peer_waypoint ();
		[retobj retain];
		[retobj autorelease];
		mt_dummy_use (retval);
		res = retobj;
	}

exception_handling:
	xamarin_mono_object_release (&retval);
	xamarin_mono_object_release (&mthis);
	xamarin_mono_object_release (&reflection_method);

	MONO_THREAD_DETACH;
	if (exception_gchandle != INVALID_GCHANDLE)
		xamarin_process_managed_exception_gchandle (exception_gchandle);
	return res;
}




@interface __monomac_internal_ActionDispatcher : NSObject {
}
	-(void) release;
	-(id) retain;
	-(GCHandle) xamarinGetGCHandle;
	-(bool) xamarinSetGCHandle: (GCHandle) gchandle flags: (enum XamarinGCHandleFlags) flags;
	-(enum XamarinGCHandleFlags) xamarinGetFlags;
	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags;
	-(void) __monomac_internal_ActionDispatcher_activated:(NSObject *)p0;
	-(void) __monomac_internal_ActionDispatcher_doubleActivated:(NSObject *)p0;
	-(BOOL) worksWhenModal;
	-(BOOL) conformsToProtocol:(void *)p0;
@end

@implementation __monomac_internal_ActionDispatcher {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(void) __monomac_internal_ActionDispatcher_activated:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x16A22);
	}

	-(void) __monomac_internal_ActionDispatcher_doubleActivated:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x16B22);
	}

	-(BOOL) worksWhenModal
	{
		static MonoMethod *managed_method = NULL;
		return native_to_managed_trampoline_2 (self, _cmd, &managed_method, 0x16C22);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation NSApplicationDelegate {
}

	-(id) init
	{
		static MonoMethod *managed_method = NULL;
		bool call_super = false;
		id rv = native_to_managed_trampoline_3 (self, _cmd, &managed_method, &call_super, 0x1B822);
		if (call_super && rv) {
			struct objc_super super = {  rv, [NSObject class] };
			rv = ((id (*)(objc_super*, SEL)) objc_msgSendSuper) (&super, @selector (init));
		}
		return rv;
	}
@end
#pragma clang diagnostic pop

@interface Foundation_NSDispatcher : NSObject {
}
	-(void) release;
	-(id) retain;
	-(GCHandle) xamarinGetGCHandle;
	-(bool) xamarinSetGCHandle: (GCHandle) gchandle flags: (enum XamarinGCHandleFlags) flags;
	-(enum XamarinGCHandleFlags) xamarinGetFlags;
	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags;
	-(void) xamarinApplySelector;
	-(BOOL) conformsToProtocol:(void *)p0;
	-(id) init;
@end

@implementation Foundation_NSDispatcher {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(void) xamarinApplySelector
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x42922);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}

	-(id) init
	{
		static MonoMethod *managed_method = NULL;
		bool call_super = false;
		id rv = native_to_managed_trampoline_3 (self, _cmd, &managed_method, &call_super, 0x42822);
		if (call_super && rv) {
			struct objc_super super = {  rv, [NSObject class] };
			rv = ((id (*)(objc_super*, SEL)) objc_msgSendSuper) (&super, @selector (init));
		}
		return rv;
	}
@end

@interface __MonoMac_NSSynchronizationContextDispatcher : Foundation_NSDispatcher {
}
	-(void) xamarinApplySelector;
@end

@implementation __MonoMac_NSSynchronizationContextDispatcher {
}

	-(void) xamarinApplySelector
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x42C22);
	}
@end

@interface Foundation_NSAsyncDispatcher : Foundation_NSDispatcher {
}
	-(void) xamarinApplySelector;
	-(id) init;
@end

@implementation Foundation_NSAsyncDispatcher {
}

	-(void) xamarinApplySelector
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x42E22);
	}

	-(id) init
	{
		static MonoMethod *managed_method = NULL;
		bool call_super = false;
		id rv = native_to_managed_trampoline_3 (self, _cmd, &managed_method, &call_super, 0x42D22);
		if (call_super && rv) {
			struct objc_super super = {  rv, [Foundation_NSDispatcher class] };
			rv = ((id (*)(objc_super*, SEL)) objc_msgSendSuper) (&super, @selector (init));
		}
		return rv;
	}
@end

@interface __MonoMac_NSAsyncSynchronizationContextDispatcher : Foundation_NSAsyncDispatcher {
}
	-(void) xamarinApplySelector;
@end

@implementation __MonoMac_NSAsyncSynchronizationContextDispatcher {
}

	-(void) xamarinApplySelector
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x43022);
	}
@end

@implementation __NSGestureRecognizerToken {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}

	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}
@end

@implementation __NSGestureRecognizerParameterlessToken {
}

	-(void) target
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x18722);
	}
@end

@implementation __NSGestureRecognizerParametrizedToken {
}

	-(void) target:(NSGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x18822);
	}
@end

@interface __NSClickGestureRecognizer : __NSGestureRecognizerToken {
}
	-(void) target:(NSClickGestureRecognizer *)p0;
@end

@implementation __NSClickGestureRecognizer {
}

	-(void) target:(NSClickGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x18C22);
	}
@end

@interface __NSMagnificationGestureRecognizer : __NSGestureRecognizerToken {
}
	-(void) target:(NSMagnificationGestureRecognizer *)p0;
@end

@implementation __NSMagnificationGestureRecognizer {
}

	-(void) target:(NSMagnificationGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x19022);
	}
@end

@interface __NSPanGestureRecognizer : __NSGestureRecognizerToken {
}
	-(void) target:(NSPanGestureRecognizer *)p0;
@end

@implementation __NSPanGestureRecognizer {
}

	-(void) target:(NSPanGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x19422);
	}
@end

@interface __NSPressGestureRecognizer : __NSGestureRecognizerToken {
}
	-(void) target:(NSPressGestureRecognizer *)p0;
@end

@implementation __NSPressGestureRecognizer {
}

	-(void) target:(NSPressGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x19822);
	}
@end

@interface __NSRotationGestureRecognizer : __NSGestureRecognizerToken {
}
	-(void) target:(NSRotationGestureRecognizer *)p0;
@end

@implementation __NSRotationGestureRecognizer {
}

	-(void) target:(NSRotationGestureRecognizer *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x19C22);
	}
@end

@interface __NSObject_Disposer : NSObject {
}
	-(void) release;
	-(id) retain;
	-(GCHandle) xamarinGetGCHandle;
	-(bool) xamarinSetGCHandle: (GCHandle) gchandle flags: (enum XamarinGCHandleFlags) flags;
	-(enum XamarinGCHandleFlags) xamarinGetFlags;
	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags;
	+(void) drain:(NSObject *)p0;
	-(BOOL) conformsToProtocol:(void *)p0;
	-(id) init;
@end

@implementation __NSObject_Disposer {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	+(void) drain:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_5 (self, _cmd, &managed_method, p0, 0x46A22);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}

	-(id) init
	{
		static MonoMethod *managed_method = NULL;
		bool call_super = false;
		id rv = native_to_managed_trampoline_3 (self, _cmd, &managed_method, &call_super, 0x46722);
		if (call_super && rv) {
			struct objc_super super = {  rv, [NSObject class] };
			rv = ((id (*)(objc_super*, SEL)) objc_msgSendSuper) (&super, @selector (init));
		}
		return rv;
	}
@end

@implementation AppDelegate {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(void) applicationDidFinishLaunching:(NSNotification *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x3);
	}

	-(void) applicationWillTerminate:(NSNotification *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x5);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}

	-(id) init
	{
		static MonoMethod *managed_method = NULL;
		bool call_super = false;
		id rv = native_to_managed_trampoline_3 (self, _cmd, &managed_method, &call_super, 0x7);
		if (call_super && rv) {
			struct objc_super super = {  rv, [NSObject class] };
			rv = ((id (*)(objc_super*, SEL)) objc_msgSendSuper) (&super, @selector (init));
		}
		return rv;
	}
@end

@implementation KeyGenController {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(void) CreateSymetricKey:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0xB);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}
@end

@implementation AESKeyGen {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(NSTextField *) EntryBloc
	{
		static MonoMethod *managed_method = NULL;
		return native_to_managed_trampoline_6 (self, _cmd, &managed_method, 0xF);
	}

	-(void) setEntryBloc:(NSTextField *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x11);
	}

	-(NSTextField *) IV
	{
		static MonoMethod *managed_method = NULL;
		return native_to_managed_trampoline_6 (self, _cmd, &managed_method, 0x13);
	}

	-(void) setIV:(NSTextField *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x15);
	}

	-(NSPopUpButton *) KeySizeOutlet
	{
		static MonoMethod *managed_method = NULL;
		return native_to_managed_trampoline_6 (self, _cmd, &managed_method, 0x17);
	}

	-(void) setKeySizeOutlet:(NSPopUpButton *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x19);
	}

	-(void) viewDidDisappear
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_4 (self, _cmd, &managed_method, 0x1B);
	}

	-(void) KeySizeButton:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x1D);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}
@end

@implementation MainViewController {
	XamarinObject __monoObjectGCHandle;
}
	-(void) release
	{
		xamarin_release_trampoline (self, _cmd);
	}

	-(id) retain
	{
		return xamarin_retain_trampoline (self, _cmd);
	}

	-(GCHandle) xamarinGetGCHandle
	{
		return __monoObjectGCHandle.gc_handle;
	}

	-(bool) xamarinSetGCHandle: (GCHandle) gc_handle flags: (enum XamarinGCHandleFlags) flags
	{
		if (((flags & XamarinGCHandleFlags_InitialSet) == XamarinGCHandleFlags_InitialSet) && __monoObjectGCHandle.gc_handle != INVALID_GCHANDLE) {
			return false;
		}
		flags = (enum XamarinGCHandleFlags) (flags & ~XamarinGCHandleFlags_InitialSet);
		__monoObjectGCHandle.gc_handle = gc_handle;
		__monoObjectGCHandle.flags = flags;
		__monoObjectGCHandle.native_object = self;
		return true;
	}

	-(enum XamarinGCHandleFlags) xamarinGetFlags
	{
		return __monoObjectGCHandle.flags;
	}

	-(void) xamarinSetFlags: (enum XamarinGCHandleFlags) flags
	{
		__monoObjectGCHandle.flags = flags;
	}


	-(void) KeyGenButton:(NSObject *)p0
	{
		static MonoMethod *managed_method = NULL;
		native_to_managed_trampoline_1 (self, _cmd, &managed_method, p0, 0x21);
	}
	-(BOOL) conformsToProtocol: (void *) protocol
	{
		GCHandle exception_gchandle;
		BOOL rv = xamarin_invoke_conforms_to_protocol (self, (Protocol *) protocol, &exception_gchandle);
		xamarin_process_managed_exception_gchandle (exception_gchandle);
		return rv;
	}
@end

	static MTClassMap __xamarin_class_map [] = {
		{ NULL, 0xAD22 /* #0 'NSObject' => 'Foundation.NSObject, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1522 /* #1 '__monomac_internal_ActionDispatcher' => 'AppKit.ActionDispatcher, Xamarin.Mac' */, (MTTypeFlags) (2) /* UserType */ },
		{ NULL, 0x2F22 /* #2 'NSResponder' => 'AppKit.NSResponder, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1722 /* #3 'NSApplication' => 'AppKit.NSApplication, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2A22 /* #4 'NSView' => 'AppKit.NSView, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1922 /* #5 'NSControl' => 'AppKit.NSControl, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1822 /* #6 'NSButton' => 'AppKit.NSButton, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2822 /* #7 'NSPopUpButton' => 'AppKit.NSPopUpButton, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2922 /* #8 'NSTextField' => 'AppKit.NSTextField, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2D22 /* #9 'NSWindow' => 'AppKit.NSWindow, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2E22 /* #10 'NSApplicationDelegate' => 'AppKit.NSApplicationDelegate, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x3022 /* #11 'NSStoryboard' => 'AppKit.NSStoryboard, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x3122 /* #12 'NSViewController' => 'AppKit.NSViewController, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x3222 /* #13 'NSWindowController' => 'AppKit.NSWindowController, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xA722 /* #14 'Foundation_NSDispatcher' => 'Foundation.NSDispatcher, Xamarin.Mac' */, (MTTypeFlags) (2) /* UserType */ },
		{ NULL, 0xA822 /* #15 '__MonoMac_NSSynchronizationContextDispatcher' => 'Foundation.NSSynchronizationContextDispatcher, Xamarin.Mac' */, (MTTypeFlags) (2) /* UserType */ },
		{ NULL, 0xA922 /* #16 'Foundation_NSAsyncDispatcher' => 'Foundation.NSAsyncDispatcher, Xamarin.Mac' */, (MTTypeFlags) (2) /* UserType */ },
		{ NULL, 0xAA22 /* #17 '__MonoMac_NSAsyncSynchronizationContextDispatcher' => 'Foundation.NSAsyncSynchronizationContextDispatcher, Xamarin.Mac' */, (MTTypeFlags) (2) /* UserType */ },
		{ NULL, 0xAB22 /* #18 'NSAutoreleasePool' => 'Foundation.NSAutoreleasePool, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xAC22 /* #19 'NSBundle' => 'Foundation.NSBundle, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xB322 /* #20 'NSRunLoop' => 'Foundation.NSRunLoop, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xB422 /* #21 'NSString' => 'Foundation.NSString, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xBA22 /* #22 'NSException' => 'Foundation.NSException, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xBB22 /* #23 'NSNotification' => 'Foundation.NSNotification, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1B22 /* #24 '__NSGestureRecognizerToken' => 'AppKit.NSGestureRecognizer+Token, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1C22 /* #25 '__NSGestureRecognizerParameterlessToken' => 'AppKit.NSGestureRecognizer+ParameterlessDispatch, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1D22 /* #26 '__NSGestureRecognizerParametrizedToken' => 'AppKit.NSGestureRecognizer+ParametrizedDispatch, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1A22 /* #27 'NSGestureRecognizer' => 'AppKit.NSGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x1F22 /* #28 '__NSClickGestureRecognizer' => 'AppKit.NSClickGestureRecognizer+Callback, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1E22 /* #29 'NSClickGestureRecognizer' => 'AppKit.NSClickGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2122 /* #30 '__NSMagnificationGestureRecognizer' => 'AppKit.NSMagnificationGestureRecognizer+Callback, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x2022 /* #31 'NSMagnificationGestureRecognizer' => 'AppKit.NSMagnificationGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2322 /* #32 '__NSPanGestureRecognizer' => 'AppKit.NSPanGestureRecognizer+Callback, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x2222 /* #33 'NSPanGestureRecognizer' => 'AppKit.NSPanGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2522 /* #34 '__NSPressGestureRecognizer' => 'AppKit.NSPressGestureRecognizer+Callback, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x2422 /* #35 'NSPressGestureRecognizer' => 'AppKit.NSPressGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0x2722 /* #36 '__NSRotationGestureRecognizer' => 'AppKit.NSRotationGestureRecognizer+Callback, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x2622 /* #37 'NSRotationGestureRecognizer' => 'AppKit.NSRotationGestureRecognizer, Xamarin.Mac' */, (MTTypeFlags) (0) /* None */ },
		{ NULL, 0xB122 /* #38 '__NSObject_Disposer' => 'Foundation.NSObject+NSObject_Disposer, Xamarin.Mac' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1 /* #39 'AppDelegate' => 'NeuralCrypto.AppDelegate, NeuralCrypto' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x9 /* #40 'KeyGenController' => 'NeuralCrypto.KeyGen.KeyGenController, NeuralCrypto' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0xD /* #41 'AESKeyGen' => 'NeuralCrypto.KeyGen.AESKeyGen, NeuralCrypto' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0x1F /* #42 'MainViewController' => 'NeuralCrypto.Main.MainViewController, NeuralCrypto' */, (MTTypeFlags) (3) /* CustomType, UserType */ },
		{ NULL, 0 },
	};

	static const MTAssembly __xamarin_registration_assemblies [] = {
		{ "CryptoEngine", "77ee46a9-51f1-4c3d-b3e6-cd48d6efb6b2" }, 
		{ "mscorlib", "b72a0fe8-06e4-449f-8c07-8f96d2561087" }, 
		{ "BouncyCastle.Cryptography", "4af9c6d3-48fe-476e-9c31-fddad729a1f5" }, 
		{ "netstandard", "2a64da42-7a34-448c-b7a1-996c85e24072" }, 
		{ "System.Core", "bb72d2d3-127c-4b80-85d5-c3aa1b29a208" }, 
		{ "System", "38dbd4ec-0d38-4f7d-bd28-a49964fb8300" }, 
		{ "Mono.Security", "0beceb62-ba8f-4e53-b552-2bada2ed231c" }, 
		{ "System.Xml", "3ed2bc6c-7a18-45fb-b5ee-bf7cf8d2ae17" }, 
		{ "System.Numerics", "c2cd376c-2ee7-4583-b011-93506e2dc569" }, 
		{ "System.Data", "44404333-b7e6-4281-8985-f462e5514bc8" }, 
		{ "System.Transactions", "dab90839-b83b-4e10-bcfa-15227239645c" }, 
		{ "System.Data.DataSetExtensions", "96b58954-2ed2-4637-83b5-6a1e31e7dc5d" }, 
		{ "System.Drawing.Common", "d9686691-acb2-45e2-bfb9-3defb4d83b82" }, 
		{ "System.IO.Compression", "878add3a-36b1-45c3-834d-f3d30f5f8cd3" }, 
		{ "System.IO.Compression.FileSystem", "e876f142-dbdd-4197-9e41-1bcc4d29dc0b" }, 
		{ "System.ComponentModel.Composition", "61178e63-5b01-4d9a-8c3c-d44935ccba86" }, 
		{ "System.Net.Http", "9df34f59-235f-428c-a694-17d225f602d5" }, 
		{ "Xamarin.Mac", "67dda901-fec0-40ec-b52b-6602a281af31" }, 
		{ "System.Runtime.Serialization", "12b24cd4-2442-47ee-bbf0-f2ac8f8833f8" }, 
		{ "System.ServiceModel.Internals", "31c71dc6-ca1a-4bb0-93d0-1d20bde548d0" }, 
		{ "System.Web.Services", "68899b45-7ffb-4528-8f50-14e03bab1357" }, 
		{ "System.Xml.Linq", "95435d23-65a2-44d4-804a-eb1170a10d74" }, 
		{ "Microsoft.Win32.Primitives", "7933f5e3-cd1e-4967-ba9f-efce39c1d66a" }, 
		{ "Microsoft.Win32.Registry.AccessControl", "eb81a864-f2b6-4436-a61c-41326735c405" }, 
		{ "Microsoft.Win32.Registry", "2171c2c7-2276-46a8-808f-9d01db18c955" }, 
		{ "System.AppContext", "558eb1ff-c467-4fbf-85df-68748232d914" }, 
		{ "System.Buffers", "f3ed66a5-c6df-46d4-b32b-d144097aaeba" }, 
		{ "System.Collections.Concurrent", "ab2702d8-97a0-4f83-8686-7c3e71a69fff" }, 
		{ "System.Collections", "445aa35a-ea86-46fa-84db-4beae1723fb6" }, 
		{ "System.Collections.NonGeneric", "ac801d37-6cc8-4e13-b3bf-6a79df3a256c" }, 
		{ "System.Collections.Specialized", "47c7680a-852c-4f6e-95f4-c58ee7f8085c" }, 
		{ "System.ComponentModel.Annotations", "1ee9eb27-2e1f-4691-8790-b8f62009ad5d" }, 
		{ "System.ComponentModel.DataAnnotations", "bea9595e-b8af-40c0-abd1-11181d7561d1" }, 
		{ "System.ComponentModel", "01c220e5-39f3-44ec-8dc1-d36554c8c9f7" }, 
		{ "System.ComponentModel.EventBasedAsync", "d23375bc-5f80-4751-90de-c0a0fe00feb4" }, 
		{ "System.ComponentModel.Primitives", "1a5622bf-588c-455e-9d93-d8ddd438b814" }, 
		{ "System.ComponentModel.TypeConverter", "f8100501-e08b-45a6-9d25-3e9ed9a23054" }, 
		{ "System.Console", "e3c1ef18-aa94-4333-82e7-7cf73896fd2d" }, 
		{ "System.Data.Common", "4a01d280-bf8f-4fa9-a7cc-b3e1f6507e2d" }, 
		{ "System.Data.SqlClient", "b1a6a65d-0b5f-4845-9b6e-563fd64b4cb7" }, 
		{ "System.Diagnostics.Contracts", "cf6dc912-d383-4526-932d-19ddbf109693" }, 
		{ "System.Diagnostics.Debug", "2d399a9f-df27-4879-bb11-b7dfd7a7d51b" }, 
		{ "System.Diagnostics.FileVersionInfo", "68e8c1ed-a4c6-4dbf-a13a-76a926aa3aa3" }, 
		{ "System.Diagnostics.Process", "ae0e11d3-dcb4-47ea-abd7-20e9ff04cd54" }, 
		{ "System.Diagnostics.StackTrace", "40f24798-5ddd-4ba8-a9e8-a2d93268edd9" }, 
		{ "System.Diagnostics.TextWriterTraceListener", "ace898dc-106f-4982-bcae-c3062085e82b" }, 
		{ "System.Diagnostics.Tools", "5298cb59-d381-4182-8f7b-1cbfc26b6799" }, 
		{ "System.Diagnostics.TraceEvent", "03db8bf2-a538-4c42-9dff-535ef71a0df2" }, 
		{ "System.Diagnostics.TraceSource", "e3adfb1a-515c-45d7-b452-2c0700747332" }, 
		{ "System.Diagnostics.Tracing", "ec1de3f2-554c-4e30-9d7f-53d80a5eabb0" }, 
		{ "System.Drawing.Primitives", "58b6a553-69df-4b1f-b7d8-f5288ee9a3ed" }, 
		{ "System.Dynamic.Runtime", "574d5b39-c251-4674-a991-776ba66be648" }, 
		{ "System.Globalization.Calendars", "28b1b89c-91dd-4b69-974e-904a75d7088b" }, 
		{ "System.Globalization", "8c852e53-26c5-4ba9-8176-88ca8cca1b9d" }, 
		{ "System.Globalization.Extensions", "5f87c686-7644-45f3-80b9-ea47606907ad" }, 
		{ "System.IO.Compression.ZipFile", "a7ca4aeb-c057-4c46-9af6-0912379f0075" }, 
		{ "System.IO", "0a133204-8a78-4db6-a267-32f89beb16ea" }, 
		{ "System.IO.FileSystem.AccessControl", "c9dd99fd-4484-496c-b9e5-d38cba2fda08" }, 
		{ "System.IO.FileSystem", "569c2138-12ac-415c-8fc5-668c3139fc88" }, 
		{ "System.IO.FileSystem.DriveInfo", "1afe5d0b-cac3-4c2f-9c87-1c7215d8c0cd" }, 
		{ "System.IO.FileSystem.Primitives", "8f47ae37-e3d1-4330-9f02-b22de3da75e9" }, 
		{ "System.IO.FileSystem.Watcher", "e6cd30f4-8528-4ee7-94ac-68930df5c3fc" }, 
		{ "System.IO.IsolatedStorage", "5908fc0f-72e5-4d82-99dd-1649a0b89e33" }, 
		{ "System.IO.MemoryMappedFiles", "ff7b512f-6e67-4675-9c91-e618c3273e76" }, 
		{ "System.IO.Pipes", "0e707e51-f131-4de0-b94b-c947c132c966" }, 
		{ "System.IO.UnmanagedMemoryStream", "b0fc72be-65c0-4ce3-82cc-94b72ca8e561" }, 
		{ "System.Linq", "cf22f0a8-ce77-4e9a-8f22-60d5dd9bb719" }, 
		{ "System.Linq.Expressions", "d0a4f364-29c7-443a-bf62-2ebe02cef075" }, 
		{ "System.Linq.Parallel", "a26e61b3-df82-4289-80e5-9a88305ba2bc" }, 
		{ "System.Linq.Queryable", "2404323e-ee52-4cb2-bb8d-1014e325f7bd" }, 
		{ "System.Memory", "24a92820-8a91-4489-985a-565d37c1904f" }, 
		{ "System.Net.AuthenticationManager", "3caa0881-ee60-4495-8204-96d36172f861" }, 
		{ "System.Net.Cache", "d8dc4091-8f74-447b-9651-4fa7f1fc8bda" }, 
		{ "System.Net.HttpListener", "c03bdcfc-64c3-453a-a9d0-5fe7797fc88f" }, 
		{ "System.Net.Mail", "1ea50be9-262f-40b0-b57e-0de27152b1b7" }, 
		{ "System.Net.NameResolution", "f43a88ab-65b8-4c04-87a5-1ed2afd42398" }, 
		{ "System.Net.NetworkInformation", "3791580b-f53e-4625-9004-2e0e156b5dd3" }, 
		{ "System.Net.Ping", "f061a625-f160-41bc-a431-fc4699e4a440" }, 
		{ "System.Net.Primitives", "2ea30488-f8a8-40e1-b03d-9721a41283b8" }, 
		{ "System.Net.Requests", "d4686e13-a7fe-483e-95c3-610f33c234c3" }, 
		{ "System.Net.Security", "c5320889-7711-4bcc-a068-9f22ecafa43f" }, 
		{ "System.Net.ServicePoint", "2ddd9747-21a1-4c53-8f63-0ce956717e88" }, 
		{ "System.Net.Sockets", "ab0b8df1-6723-42d7-a6ce-2bfac82752a1" }, 
		{ "System.Net.Utilities", "23f12b87-64b9-4c8e-9f6d-3f5bfcce1825" }, 
		{ "System.Net.WebHeaderCollection", "5271ceea-b2b3-4e74-a5d3-91d3c6077d97" }, 
		{ "System.Net.WebSockets.Client", "aa518d8e-8a7f-4044-ba55-34e6a5199162" }, 
		{ "System.Net.WebSockets", "7a842de9-d019-423e-a5fe-c835046b144d" }, 
		{ "System.ObjectModel", "c138ff4e-ded1-4c27-b9d3-27bf3bbff254" }, 
		{ "System.Reflection.DispatchProxy", "1b7aed8c-5976-4b88-a42a-6861592c692b" }, 
		{ "System.Reflection", "254e09d7-c57b-4399-8c84-00f54177a638" }, 
		{ "System.Reflection.Emit", "3ca3f29f-f4ce-4f18-ba99-b93431ed6ded" }, 
		{ "System.Reflection.Emit.ILGeneration", "86dc7697-a72f-40b3-b38c-a7bc949aafae" }, 
		{ "System.Reflection.Emit.Lightweight", "0f5f3e71-3462-4a17-883f-c74e6e6ef55f" }, 
		{ "System.Reflection.Extensions", "9d83b68a-5924-4370-928b-7c8ec14344a0" }, 
		{ "System.Reflection.Primitives", "94637688-1de2-4389-95bb-5f294c51934d" }, 
		{ "System.Reflection.TypeExtensions", "fea456f7-78d7-486a-8d73-e417f4a92eab" }, 
		{ "System.Resources.Reader", "c8e18073-4b77-457a-8984-5a48368cc318" }, 
		{ "System.Resources.ReaderWriter", "2a5faf72-175b-42bd-b690-f91957cf654a" }, 
		{ "System.Resources.ResourceManager", "858033b9-99ff-46a1-828a-8d67074a85ed" }, 
		{ "System.Resources.Writer", "98b84867-17a4-4ba6-9c98-f5a870325dbe" }, 
		{ "System.Runtime.CompilerServices.VisualC", "822f85c2-f873-4abe-8fbf-96fb5b0851a7" }, 
		{ "System.Runtime", "1276392b-b824-4a83-85d5-50ec6d0e8acf" }, 
		{ "System.Runtime.Extensions", "4b44b311-85f2-43b2-bf3e-e7a0d1298217" }, 
		{ "System.Runtime.Handles", "bdf8b57b-51e9-48dd-9c2d-0c71e4c233e3" }, 
		{ "System.Runtime.InteropServices", "1dd466d3-dd1c-4701-925b-002d900be5f3" }, 
		{ "System.Runtime.InteropServices.RuntimeInformation", "dc7a6173-976e-4356-90c4-d3a47bee42c4" }, 
		{ "System.Runtime.InteropServices.WindowsRuntime", "9f076af5-9725-4ac1-a476-5a8649701e06" }, 
		{ "System.Runtime.Loader", "c0068b46-9c85-4dec-a09d-b34d15c917f0" }, 
		{ "System.Runtime.Numerics", "32eeb674-92d4-41a3-b9bc-ca790924fe73" }, 
		{ "System.Runtime.Serialization.Formatters", "0328d044-100f-4cbb-b37b-8a0fe94461a6" }, 
		{ "System.Runtime.Serialization.Json", "4108d79b-c6c3-4116-bc50-e9bb556918ac" }, 
		{ "System.Runtime.Serialization.Primitives", "a893c645-6b20-4b6f-9a78-59f3d632f050" }, 
		{ "System.Runtime.Serialization.Xml", "c4f67653-04a1-4f5a-8857-e6331ad465d8" }, 
		{ "System.Security.AccessControl", "cc1bbafe-57e6-48e4-96e2-2194505f96cb" }, 
		{ "System.Security.Claims", "18955cb9-51a9-468f-b341-3bccee5a2489" }, 
		{ "System.Security.Cryptography.Algorithms", "40291730-775f-4d6a-9b37-da53616e06a8" }, 
		{ "System.Security.Cryptography.Cng", "ece87580-65b2-4ba8-869f-dd29b1e5c0bf" }, 
		{ "System.Security.Cryptography.Csp", "de90e618-185c-40fd-8c35-b75a970a862e" }, 
		{ "System.Security.Cryptography.DeriveBytes", "3b32d58e-c7d6-4551-be73-7850da47568d" }, 
		{ "System.Security.Cryptography.Encoding", "121a3e29-e987-498e-9fce-a8e7b8c670df" }, 
		{ "System.Security.Cryptography.Encryption.Aes", "66c43e2a-113a-4b2a-a198-efffb6ab46c0" }, 
		{ "System.Security.Cryptography.Encryption", "8ff14537-2826-42de-ba0d-67a93cb689a5" }, 
		{ "System.Security.Cryptography.Encryption.ECDiffieHellman", "bbda3503-8a66-4d68-88a3-752ff558fc1a" }, 
		{ "System.Security.Cryptography.Encryption.ECDsa", "91cde150-7f35-43aa-8d53-85704857789a" }, 
		{ "System.Security.Cryptography.Hashing.Algorithms", "eefe29fd-1475-4e70-ab6e-48343b59e3b5" }, 
		{ "System.Security.Cryptography.Hashing", "5ead7dd2-15b2-4639-a6ff-abdf28310e08" }, 
		{ "System.Security.Cryptography.OpenSsl", "1c36d2b4-c81e-4127-ac0e-480bc59279a8" }, 
		{ "System.Security.Cryptography.Pkcs", "d9699487-601f-445c-a0c0-21bb896e0a96" }, 
		{ "System.Security", "2bc9c5cc-ff0f-4250-9461-4a1e6b53d952" }, 
		{ "System.Security.Cryptography.Primitives", "9a845c7c-3a41-4f90-b7ec-2e0a8d9f2106" }, 
		{ "System.Security.Cryptography.ProtectedData", "45751a75-4c65-45db-9ca0-8d545a053b49" }, 
		{ "System.Security.Cryptography.RandomNumberGenerator", "b5248f69-b124-47c3-839b-c8d259f718c5" }, 
		{ "System.Security.Cryptography.RSA", "9859dcb7-eafb-42b5-82ad-059c08af2fa0" }, 
		{ "System.Security.Cryptography.X509Certificates", "2dd3441a-f637-4ffb-9db5-4a7eb5c35477" }, 
		{ "System.Security.Principal", "00bf80c7-e375-470c-b986-1ccd128d1918" }, 
		{ "System.Security.Principal.Windows", "1f76e39e-363c-4435-bfa7-7f0028a2055d" }, 
		{ "System.Security.SecureString", "37bd4884-797f-4023-87a6-5f4e10b37bd6" }, 
		{ "System.ServiceModel.Duplex", "ba0b246d-824c-4797-a4cd-0760005e36f2" }, 
		{ "System.ServiceModel", "6d1f03c0-3e3b-4cf7-8cf2-57e0a77ee8dd" }, 
		{ "System.IdentityModel", "eaa86724-76a1-41bf-8fee-4d3dfe5be56f" }, 
		{ "System.ServiceModel.Http", "ddb1ee10-8cd7-41b5-ae16-52e5ae5efb0d" }, 
		{ "System.ServiceModel.NetTcp", "f91149f2-576b-4365-bde8-4781a5c49482" }, 
		{ "System.ServiceModel.Primitives", "f7e068e7-0545-4712-9c20-ef648ac693e3" }, 
		{ "System.ServiceModel.Security", "66c6af3f-6fa4-4818-bbeb-31440d445559" }, 
		{ "System.ServiceProcess.ServiceController", "5cb948fe-ef4e-46d6-8ad0-7c195d355955" }, 
		{ "System.Text.Encoding.CodePages", "bf86b7b6-8a49-447c-b35d-c01020c339bc" }, 
		{ "System.Text.Encoding", "ab00b7fa-854a-4ab2-9382-b2ebfdf96d7b" }, 
		{ "System.Text.Encoding.Extensions", "42329a46-4f4d-41a3-b9dc-e294afb8beda" }, 
		{ "System.Text.RegularExpressions", "cb99df8b-f6e9-490f-9a65-e0557ce8274e" }, 
		{ "System.Threading.AccessControl", "c45b8d21-52b3-4cae-a6ff-6f6788699a49" }, 
		{ "System.Threading", "41ddade7-3378-4eab-9e8c-f5bf232513f9" }, 
		{ "System.Threading.Overlapped", "713ef4ad-2397-4f4f-92be-d20cefcf9394" }, 
		{ "System.Threading.Tasks", "c9f85bc2-fba4-4c71-9d02-1d9e3510ee3d" }, 
		{ "System.Threading.Tasks.Extensions", "8e5b6229-d7ad-4bf4-a9fe-c326812c3d8e" }, 
		{ "System.Threading.Tasks.Parallel", "e64e06ae-f227-4015-866c-62510d69ed90" }, 
		{ "System.Threading.Thread", "84a20e5e-2c7c-4e1e-bbcc-98d72b34fc53" }, 
		{ "System.Threading.ThreadPool", "b734c56d-8a6b-4d12-b5da-f6b77a2c731f" }, 
		{ "System.Threading.Timer", "ca76d657-dc4a-4949-9aef-ca6ceed494b9" }, 
		{ "System.ValueTuple", "aa5000d0-1614-460e-9901-698c0bba5a1d" }, 
		{ "System.Xml.ReaderWriter", "d43d42b4-3151-42e1-b710-3aa280271abe" }, 
		{ "System.Xml.XDocument", "dab43d10-f2be-4ca6-93a0-caa39e51e54b" }, 
		{ "System.Xml.XmlDocument", "36a1c111-cde3-4781-9177-bafbac781427" }, 
		{ "System.Xml.XmlSerializer", "70e7453d-0fa3-49fa-89aa-a7381a5a6447" }, 
		{ "System.Xml.XPath", "7f84278d-b6e8-4998-84a7-c44e2577ff7d" }, 
		{ "System.Xml.XPath.XDocument", "61eb357e-32ed-4a1d-94e6-cc5d4a11a075" }, 
		{ "System.Xml.XPath.XmlDocument", "010e898e-d8b2-4b15-bf75-e8dc0d421263" }, 
		{ "System.Xml.Xsl.Primitives", "f7c424ab-8277-4c9a-9147-7b6857f36431" }, 
		{ "NeuralCrypto", "8cab01e6-5d2d-4e38-a0d5-3f668cb4e539" }
	};

	static const MTFullTokenReference __xamarin_token_references [] = {
		{ /* #1 = 0x1 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x2000003 /* NeuralCrypto.AppDelegate */ },
		{ /* #2 = 0x3 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000003 /* System.Void NeuralCrypto.AppDelegate::DidFinishLaunching(Foundation.NSNotification) */ },
		{ /* #3 = 0x5 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000004 /* System.Void NeuralCrypto.AppDelegate::WillTerminate(Foundation.NSNotification) */ },
		{ /* #4 = 0x7 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000002 /* System.Void NeuralCrypto.AppDelegate::.ctor() */ },
		{ /* #5 = 0x9 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x2000004 /* NeuralCrypto.KeyGen.KeyGenController */ },
		{ /* #6 = 0xB */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000006 /* System.Void NeuralCrypto.KeyGen.KeyGenController::CreateSymetricKey(Foundation.NSObject) */ },
		{ /* #7 = 0xD */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x2000005 /* NeuralCrypto.KeyGen.AESKeyGen */ },
		{ /* #8 = 0xF */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000A /* AppKit.NSTextField NeuralCrypto.KeyGen.AESKeyGen::get_EntryBloc() */ },
		{ /* #9 = 0x11 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000B /* System.Void NeuralCrypto.KeyGen.AESKeyGen::set_EntryBloc(AppKit.NSTextField) */ },
		{ /* #10 = 0x13 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000C /* AppKit.NSTextField NeuralCrypto.KeyGen.AESKeyGen::get_IV() */ },
		{ /* #11 = 0x15 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000D /* System.Void NeuralCrypto.KeyGen.AESKeyGen::set_IV(AppKit.NSTextField) */ },
		{ /* #12 = 0x17 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000E /* AppKit.NSPopUpButton NeuralCrypto.KeyGen.AESKeyGen::get_KeySizeOutlet() */ },
		{ /* #13 = 0x19 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x600000F /* System.Void NeuralCrypto.KeyGen.AESKeyGen::set_KeySizeOutlet(AppKit.NSPopUpButton) */ },
		{ /* #14 = 0x1B */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000009 /* System.Void NeuralCrypto.KeyGen.AESKeyGen::ViewDidDisappear() */ },
		{ /* #15 = 0x1D */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000010 /* System.Void NeuralCrypto.KeyGen.AESKeyGen::KeySizeButton(Foundation.NSObject) */ },
		{ /* #16 = 0x1F */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x2000006 /* NeuralCrypto.Main.MainViewController */ },
		{ /* #17 = 0x21 */ 167 /* NeuralCrypto */, 0x1 /* NeuralCrypto.exe */, 0x6000013 /* System.Void NeuralCrypto.Main.MainViewController::KeyGenButton(Foundation.NSObject) */ },

	};

	static struct MTRegistrationMap __xamarin_registration_map = {
		"97731c92cc6d147825c1a39ed2c5c530a5f9a12b",
		__xamarin_registration_assemblies,
		__xamarin_class_map,
		__xamarin_token_references,
		NULL,
		NULL,
		{ NULL, NULL },
		168,
		43,
		17,
		0,
		0,
		0
	};

void xamarin_create_classes () {
	__xamarin_class_map [0].handle = objc_getClass ("NSObject");
	__xamarin_class_map [1].handle = objc_getClass ("__monomac_internal_ActionDispatcher");
	__xamarin_class_map [2].handle = objc_getClass ("NSResponder");
	__xamarin_class_map [3].handle = objc_getClass ("NSApplication");
	__xamarin_class_map [4].handle = objc_getClass ("NSView");
	__xamarin_class_map [5].handle = objc_getClass ("NSControl");
	__xamarin_class_map [6].handle = objc_getClass ("NSButton");
	__xamarin_class_map [7].handle = objc_getClass ("NSPopUpButton");
	__xamarin_class_map [8].handle = objc_getClass ("NSTextField");
	__xamarin_class_map [9].handle = objc_getClass ("NSWindow");
	__xamarin_class_map [10].handle = objc_getClass ("NSApplicationDelegate");
	__xamarin_class_map [11].handle = objc_getClass ("NSStoryboard");
	__xamarin_class_map [12].handle = objc_getClass ("NSViewController");
	__xamarin_class_map [13].handle = objc_getClass ("NSWindowController");
	__xamarin_class_map [14].handle = objc_getClass ("Foundation_NSDispatcher");
	__xamarin_class_map [15].handle = objc_getClass ("__MonoMac_NSSynchronizationContextDispatcher");
	__xamarin_class_map [16].handle = objc_getClass ("Foundation_NSAsyncDispatcher");
	__xamarin_class_map [17].handle = objc_getClass ("__MonoMac_NSAsyncSynchronizationContextDispatcher");
	__xamarin_class_map [18].handle = objc_getClass ("NSAutoreleasePool");
	__xamarin_class_map [19].handle = objc_getClass ("NSBundle");
	__xamarin_class_map [20].handle = objc_getClass ("NSRunLoop");
	__xamarin_class_map [21].handle = objc_getClass ("NSString");
	__xamarin_class_map [22].handle = objc_getClass ("NSException");
	__xamarin_class_map [23].handle = objc_getClass ("NSNotification");
	__xamarin_class_map [24].handle = objc_getClass ("__NSGestureRecognizerToken");
	__xamarin_class_map [25].handle = objc_getClass ("__NSGestureRecognizerParameterlessToken");
	__xamarin_class_map [26].handle = objc_getClass ("__NSGestureRecognizerParametrizedToken");
	__xamarin_class_map [27].handle = objc_getClass ("NSGestureRecognizer");
	__xamarin_class_map [28].handle = objc_getClass ("__NSClickGestureRecognizer");
	__xamarin_class_map [29].handle = objc_getClass ("NSClickGestureRecognizer");
	__xamarin_class_map [30].handle = objc_getClass ("__NSMagnificationGestureRecognizer");
	__xamarin_class_map [31].handle = objc_getClass ("NSMagnificationGestureRecognizer");
	__xamarin_class_map [32].handle = objc_getClass ("__NSPanGestureRecognizer");
	__xamarin_class_map [33].handle = objc_getClass ("NSPanGestureRecognizer");
	__xamarin_class_map [34].handle = objc_getClass ("__NSPressGestureRecognizer");
	__xamarin_class_map [35].handle = objc_getClass ("NSPressGestureRecognizer");
	__xamarin_class_map [36].handle = objc_getClass ("__NSRotationGestureRecognizer");
	__xamarin_class_map [37].handle = objc_getClass ("NSRotationGestureRecognizer");
	__xamarin_class_map [38].handle = objc_getClass ("__NSObject_Disposer");
	__xamarin_class_map [39].handle = [AppDelegate class];
	__xamarin_class_map [40].handle = [KeyGenController class];
	__xamarin_class_map [41].handle = [AESKeyGen class];
	__xamarin_class_map [42].handle = [MainViewController class];
	xamarin_add_registration_map (&__xamarin_registration_map, false);
}


} /* extern "C" */
