/// Immutable toggle helper for multi-select sets (chips, weekdays…).
extension SetToggle<T> on Set<T> {
  /// Returns a new set with [value] removed if present, otherwise added.
  Set<T> toggled(T value) =>
      contains(value) ? ({...this}..remove(value)) : {...this, value};
}
