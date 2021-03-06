import 'dart:async';

import 'models/triple_model.dart';
import 'package:meta/meta.dart';

typedef Disposer = Future<void> Function();

abstract class Store<Error extends Object, State extends Object> {
  late Triple<Error, State> _triple;
  late Triple<Error, State> lastTripleState;

  ///Get the complete triple value;
  Triple<Error, State> get triple => _triple;

  ///Get the [state] value;
  State get state => _triple.state;

  ///Get [loading] value;
  bool get isLoading => _triple.isLoading;

  ///Get [error] value;
  Error? get error => _triple.error;

  ///[initialState] Start this store with a value defalt.
  Store(State initialState) {
    _triple = Triple<Error, State>(state: initialState);
    lastTripleState = _triple;
  }

  ///IMPORTANT!!!
  ///THIS METHOD TO BE VISIBLE FOR OVERRIDING ONLY!!!
  @visibleForOverriding
  void propagate(Triple<Error, State> triple) {
    _triple = triple;
  }

  ///Change the State value.
  ///
  ///This also stores the state value to be retrieved using the [undo()] method when using MementoMixin
  void update(State newState) {
    final candidate =
        _triple.copyWith(state: newState, event: TripleEvent.state);
    if (candidate != _triple && candidate.state != _triple.state) {
      _triple = candidate;
      propagate(_triple);
    }
  }

  ///Change the loading value.
  void setLoading(bool newloading) {
    final candidate =
        _triple.copyWith(isLoading: newloading, event: TripleEvent.loading);
    if (candidate != _triple && candidate.isLoading != _triple.isLoading) {
      _triple = candidate;
      propagate(_triple);
    }
  }

  ///Change the error value.
  void setError(Error newError) {
    final candidate =
        _triple.copyWith(error: newError, event: TripleEvent.error);
    if (candidate != _triple && candidate.error != _triple.error) {
      _triple = candidate;
      propagate(_triple);
    }
  }

  ///Discard the store
  Future destroy();

  ///Observer the Segmented State.
  ///
  ///EXAMPLE:
  ///```dart
  ///Disposer disposer = counter.observer(
  ///   onState: (state) => print(state),
  ///   onLoading: (loading) => print(loading),
  ///   onError: (error) => print(error),
  ///);
  ///
  ///dispose();
  ///```
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool isLoading)? onLoading,
    void Function(Error error)? onError,
  });
}
