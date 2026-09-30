# Tarefas

* Corrija o erro abaixo:

``
══╡ EXCEPTION CAUGHT BY SCHEDULER LIBRARY ╞═════════════════════════════════════════════════════════
The following ProviderNotFoundException was thrown during a scheduler callback:
Error: Could not find the correct Provider<NotesController> above this NotesView Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that NotesView is under your MultiProvider/Provider<NotesController>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // Will throw a ProviderNotFoundError, because `context` is associated
      // to the widget that is the parent of `Provider<Example>`
      child: Text(context.watch<Example>().toString()),
    );
  }
  ```

  consider using `builder` like so:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Text(context.watch<Example>().toString());
      }
    );
  }
  ```

If none of these solutions work, consider asking for help on StackOverflow:
https://stackoverflow.com/questions/tagged/flutter

When the exception was thrown, this was the stack:
#0      Provider._inheritedElementOf (package:provider/src/provider.dart:377:7)
#1      Provider.of (package:provider/src/provider.dart:327:30)
#2      ReadContext.read (package:provider/src/provider.dart:683:21)
#3      _NotesViewState.initState.<anonymous closure> (package:biblia_e_harpa/src/view/notes_view.dart:20:15)
#4      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#5      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1357:11)
#6      SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1198:5)
#7      _invoke (dart:ui/hooks.dart:441:13)
#8      PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:450:5)
#9      _drawFrame (dart:ui/hooks.dart:413:31)
════════════════════════════════════════════════════════════════════════════════════════════════════

[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Error: Could not find the correct Provider<NotesController> above this _NoteEditorDialog Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that _NoteEditorDialog is under your MultiProvider/Provider<NotesController>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // Will throw a ProviderNotFoundError, because `context` is associated
      // to the widget that is the parent of `Provider<Example>`
      child: Text(context.watch<Example>().toString()),
    );
  }
  ```

  consider using `builder` like so:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Text(context.watch<Example>().toString());
      }
    );
  }
  ```

If none of these solutions work, consider asking for help on StackOverflow:
https://stackoverflow.com/questions/tagged/flutter

#0      Provider._inheritedElementOf (package:provider/src/provider.dart:377:7)
#1      Provider.of (package:provider/src/provider.dart:327:30)
#2      ReadContext.read (package:provider/src/provider.dart:683:21)
#3      _NoteEditorDialogState._save (package:biblia_e_harpa/src/view/notes_view.dart:266:32)
#4      _InkResponseState.handleTap (package:flutter/src/material/ink_well.dart:1224:21)
#5      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:362:24)
#6      TapGestureRecognizer.handleTapUp (package:flutter/src/gestures/tap.dart:758:11)
#7      BaseTapGestureRecognizer._checkUp (package:flutter/src/gestures/tap.dart:383:5)
#8      BaseTapGestureRecognizer.handlePrimaryPointer (package:flutter/src/gestures/tap.dart:314:7)
#9      PrimaryPointerGestureRecognizer.handleEvent (package:flutter/src/gestures/recognizer.dart:738:9)
#10     PointerRouter._dispatch (package:flutter/src/gestures/pointer_router.dart:97:12)
#11     PointerRouter._dispatchEventToRoutes.<anonymous closure> (package:flutter/src/gestures/pointer_router.dart:140:9)
#12     _LinkedHashMapMixin.forEach (dart:_compact_hash:721:13)
#13     PointerRouter._dispatchEventToRoutes (package:flutter/src/gestures/pointer_router.dart:138:18)
#14     PointerRouter.route (package:flutter/src/gestures/pointer_router.dart:128:7)
#15     GestureBinding.handleEvent (package:flutter/src/gestures/binding.dart:538:19)
#16     GestureBinding.dispatchEvent (package:flutter/src/gestures/binding.dart:508:22)
#17     RendererBinding.dispatchEvent (package:flutter/src/rendering/binding.dart:473:11)
#18     GestureBinding._handlePointerEventImmediately (package:flutter/src/gestures/binding.dart:447:7)
#19     GestureBinding.handlePointerEvent (package:flutter/src/gestures/binding.dart:404:5)
#20     GestureBinding._flushPointerEventQueue (package:flutter/src/gestures/binding.dart:351:7)
#21     GestureBinding._handlePointerDataPacket (package:flutter/src/gestures/binding.dart:310:9)
#22     _invoke1 (dart:ui/hooks.dart:457:13)
#23     PlatformDispatcher._dispatchPointerDataPacket (dart:ui/platform_dispatcher.dart:473:7)
#24     _dispatchPointerDataPacket (dart:ui/hooks.dart:374:31)

[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Error: Could not find the correct Provider<NotesController> above this _NoteEditorDialog Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that _NoteEditorDialog is under your MultiProvider/Provider<NotesController>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // Will throw a ProviderNotFoundError, because `context` is associated
      // to the widget that is the parent of `Provider<Example>`
      child: Text(context.watch<Example>().toString()),
    );
  }
  ```

  consider using `builder` like so:

  ```
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Text(context.watch<Example>().toString());
      }
    );
  }
  ```

If none of these solutions work, consider asking for help on StackOverflow:
https://stackoverflow.com/questions/tagged/flutter

#0      Provider._inheritedElementOf (package:provider/src/provider.dart:377:7)
#1      Provider.of (package:provider/src/provider.dart:327:30)
#2      ReadContext.read (package:provider/src/provider.dart:683:21)
#3      _NoteEditorDialogState._save (package:biblia_e_harpa/src/view/notes_view.dart:266:32)
#4      _InkResponseState.handleTap (package:flutter/src/material/ink_well.dart:1224:21)
#5      GestureRecognizer.invokeCallback (package:flutter/src/gestures/recognizer.dart:362:24)
#6      TapGestureRecognizer.handleTapUp (package:flutter/src/gestures/tap.dart:758:11)
#7      BaseTapGestureRecognizer._checkUp (package:flutter/src/gestures/tap.dart:383:5)
#8      BaseTapGestureRecognizer.handlePrimaryPointer (package:flutter/src/gestures/tap.dart:314:7)
#9      PrimaryPointerGestureRecognizer.handleEvent (package:flutter/src/gestures/recognizer.dart:738:9)
#10     PointerRouter._dispatch (package:flutter/src/gestures/pointer_router.dart:97:12)
#11     PointerRouter._dispatchEventToRoutes.<anonymous closure> (package:flutter/src/gestures/pointer_router.dart:140:9)
#12     _LinkedHashMapMixin.forEach (dart:_compact_hash:721:13)
#13     PointerRouter._dispatchEventToRoutes (package:flutter/src/gestures/pointer_router.dart:138:18)
#14     PointerRouter.route (package:flutter/src/gestures/pointer_router.dart:128:7)
#15     GestureBinding.handleEvent (package:flutter/src/gestures/binding.dart:538:19)
#16     GestureBinding.dispatchEvent (package:flutter/src/gestures/binding.dart:508:22)
#17     RendererBinding.dispatchEvent (package:flutter/src/rendering/binding.dart:473:11)
#18     GestureBinding._handlePointerEventImmediately (package:flutter/src/gestures/binding.dart:447:7)
#19     GestureBinding.handlePointerEvent (package:flutter/src/gestures/binding.dart:404:5)
#20     GestureBinding._flushPointerEventQueue (package:flutter/src/gestures/binding.dart:351:7)
#21     GestureBinding._handlePointerDataPacket (package:flutter/src/gestures/binding.dart:310:9)
#22     _invoke1 (dart:ui/hooks.dart:457:13)
#23     PlatformDispatcher._dispatchPointerDataPacket (dart:ui/platform_dispatcher.dart:473:7)
#24     _dispatchPointerDataPacket (dart:ui/hooks.dart:374:31)
``