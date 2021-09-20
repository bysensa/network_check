import 'dart:collection';
import 'package:meta/meta.dart';

class Buffer<T> with IterableMixin<T> {
  final int capacity;
  final Queue<T> _queue;

  Buffer({
    @required this.capacity,
  })  : assert(capacity != null, 'capacity is null'),
        assert(capacity > 0, 'capacity <= 0>'),
        _queue = ListQueue(capacity);

  void add(T newItem) {
    assert(newItem != null, 'newItem is null');
    if (newItem == null) {
      return;
    }
    if (_queue.length == capacity) {
      _queue.removeFirst();
    }
    _queue.add(newItem);
  }

  /// create new collection of current queue values and return iterator of new collection
  /// We must create this new collection to reduce modifications on iteration
  @override
  Iterator<T> get iterator => [..._queue].iterator;
}
