library reactter;

import '../core/reactter_types.dart';
import '../hooks/reactter_hook.dart';

/// Returns an instance of [UseState] where the prop [value] is the given type [T].
///
/// This class is in charge to handle all the rebuilds and all the events when the state change.
/// Extends from [ReactterHookAbstrac] which means this class is treated as [ReactterHook].
///
/// This example produces one simple [UseState]:
/// ```dart
///
///
/// final counter = UseState(0);
///
/// ```
/// This example produces a [UseState] with callbacks:
/// ```dart
///
///
/// final data = UseState<String?>(
///   null,
///   willUpdate: (prevValue, _) {
///
///   },
///   didUpdate: (_, newValue) {
///
///   },
/// );
///
/// ```
class UseState<T> extends ReactterHookAbstract {
  UseState(
    this.initial, {
    this.alwaysUpdate = false,
    UpdateCallback<T>? willUpdate,
    UpdateCallback<T>? didUpdate,
    ReactterHook? context,
  })  : _willUpdate = willUpdate,
        _didUpdate = didUpdate {
    context?.listenHooks([this]);
  }

  /// The initial value in state.
  T initial;

  /// Make a rebuild every time the prop [value] is setted, don't care if has the same value before.
  ///
  /// You can omit it if you are working with primitive types, but if [value]
  /// is an [Object] like [List] or [Class] is necessary to keep in true.
  final bool alwaysUpdate;

  /// Main method that will execute after [value] is updated.
  /// This is what you give as a the prop [didUpdate].
  final UpdateCallback<T>? _didUpdate;

  /// Main method that will execute before [value] going to be updated.
  /// This is what you give as a the prop [willUpdate].
  final UpdateCallback<T>? _willUpdate;

  /// A list of of listeners functions to execute when [value] is updated.
  final List<UpdateCallback<T>> _didUpdateList = [];

  /// A list of listeners functions to execute before [value] will updated.
  final List<UpdateCallback<T>> _willUpdateList = [];

  late T _value = initial;
  T get value => _value;
  set value(T value) {
    if (value != _value || alwaysUpdate || value.hashCode != _value.hashCode) {
      final oldValue = _value;

      _onWillUpdate(oldValue, value);

      _value = value;

      update();

      _onDidUpdate(oldValue, value);

      publish();
    }
  }

  /// Register a listener in [_willUpdateList] and returns a function
  /// to remove the [listener] given.
  void Function() willUpdate(UpdateCallback<T> listener) {
    _willUpdateList.add(listener);
    return () => _willUpdateList.remove(listener);
  }

  /// Register a listener in [_didUpdateList] and returns a function
  /// to remove the [listener] given.
  void Function() didUpdate(UpdateCallback<T> listener) {
    _didUpdateList.add(listener);
    return () => _didUpdateList.remove(listener);
  }

  //Reset the state to initial value
  void reset() {
    value = initial;
  }

  void update() {
    // _update?.call([key]);
  }

  /// Execute all listeners before [value] will updated.
  void _onWillUpdate(T oldValue, T value) {
    _willUpdate?.call(oldValue, value);

    for (final listener in _willUpdateList) {
      listener(oldValue, value);
    }
  }

  /// Execute all listeners when [value] is updated.
  void _onDidUpdate(T oldValue, T value) {
    _didUpdate?.call(oldValue, value);

    for (final listener in _didUpdateList) {
      listener(oldValue, value);
    }
  }
}
