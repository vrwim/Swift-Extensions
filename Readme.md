# Swift Extensions

This is a small collection of useful extensions on the standard Swift types. Currently only Array is supported. All methods are documented and ready to use.

If you have some commits I might like, don't hesitate to create a pull request.

*A small warning*: I don't check for everything right now, so you should check on empty arrays and array lengths yourself.

# Array

The methods are mostly taken from .NET, but with more coming from Java stream, SQL and MongoDB.

Some examples:

 * `func equals(otherArray: [T], comparer: (T, T) -> Bool) -> Bool` checks for equality of each item using the given closure.
 * `func distinct(comparer: (T, T) -> Bool) -> Bool) -> [T]` returns an array with only distinct (non-equal) items
 * `func groupBy<R>(groupDefiner: T -> R) -> [R:[T]]` returns a dictionary where all items of the array are split into arrays, based on the key returned from the groupDefiner closure. This closure can be as easy as `{$0.favoriteColor}`
 * `func join<R, S: Equatable, P>(otherArray: [R], thisKeyClosure: T -> S, otherKeyClosure: R -> S, resultClosure: (T,R) -> P) -> [P]` joins two arrays on a key (extracted by `thisKeyClosure` and `otherKeyClosure`) and combines them into a resulttype `P`, this can be a tuple type, so the `resultClosure` can be `{($0, $1)}` to get both items in a closure.
 * `func skip(value: Int) -> [T]` returns the array with `value` items cut off from the start