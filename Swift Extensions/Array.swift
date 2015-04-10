//
//  Array.swift
//  Swift Extensions
//
//  Created by Wim Van Renterghem on 09/04/15.
//  Copyright (c) 2015 Wim Van Renterghem. All rights reserved.
//

// TODO: make comparers Optional<> and if `is Equatable`, use ==
// TODO: add to documentation with @param, @return
// TODO: probably quite a lot of checks for empty arrays, please check yourself for the time being
// TODO: give closures better names

extension Array {
    
    typealias Comparer = (T, T) -> Bool
    
    /**
     * Checks the whole array if an item exists, by using the given closure
     *
     * @return true if any item in the array conforms to the closure
     */
    func exists(closure: T -> Bool) -> Bool {
        for item in self {
            if closure(item) {
                return true
            }
        }
        return false
    }
    
    /**
     * Finds the first item in the array that conforms to the closure
     *
     * @return the item or nil if no item in the array conforms to the closure
     */
    func find(closure: T -> Bool) -> T? {
        for item in self {
            if closure(item) {
                return item
            }
        }
        return nil
    }
    
    /**
     * Finds the first index in the array for which the value conforms to the closure
     *
     * @return the index or -1 if no item in the array conforms to the closure
     */
    func findIndex(closure: T -> Bool) -> Int {
        for counter in 0..<count {
            if closure(self[counter]) {
                return counter
            }
        }
        return -1
    }
    
    /**
     * Finds the last item in the array that conforms to the closure
     *
     * @return the item or nil if no item in the array conforms to the closure
     */
    
    func findLast(closure: T -> Bool) -> T? {
        for var counter = count - 1; counter >= 0; counter -= 1 {
            if closure(self[counter]) {
                return self[counter]
            }
        }
        return nil
    }
    
    /**
     * Finds the last index in the array for which the value conforms to the closure
     *
     * @return the index or -1 if no item in the array conforms to the closure
     */
    func findLastIndex(closure: T -> Bool) -> Int {
        for var counter = count - 1; counter >= 0; counter -= 1 {
            if closure(self[counter]) {
                return counter
            }
        }
        return -1
    }
    
    /**
     * Executes the given closure on each value of the array
     */
    func forEach(closure: (T) -> Void) {
        for item in self {
            closure(item)
        }
    }
    
    /**
     * Removes all items that conform to the given closure
     */
    mutating func removeAll(closure: (T) -> Bool) {
        for var counter = 0; counter < count; counter += 1 {
            if closure(self[counter]) {
                removeAtIndex(counter)
                counter -= 1
            }
        }
    }
    
    /**
     * Checks if every item in the array conforms to the closure
     */
    func trueForAll(closure: T -> Bool) -> Bool {
        for item in self {
            if !closure(item) {
                return false
            }
        }
        return true
    }
    
    /**
     * Compares this array with another array using the given comparer
     *
     * @return true if each element of this array is equal to the element with the same index in the other array
     */
    func equals(otherArray: [T], comparer: Comparer) -> Bool {
        if count == otherArray.count {
            for i in 0..<count {
                if !comparer(self[i], otherArray[i]) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    /**
     * Casts each item to the specified class
     *
     * @return a new array with each item as the given type
     */
    func cast<R>(type: R.Type) -> [R] {
        var result: [R] = []
        for item in self {
            result.append(item as! R)
        }
        return result
    }
    
    /**
     * Counts the elements that satisfy the given condition
     */
    func count(closure: (T) -> Bool) -> Int {
        var count = 0
        for item in self {
            count += closure(item) ? 1 : 0
        }
        return count
    }
    
    /**
     * Compares the items using the given comparer and only returns non-equal values
     * 
     * @return the first items that are unique according to the comparer
     */
    func distinct(comparer: Comparer) -> [T] {
        var result: [T] = []
        outerLoop: for item in self {
            for resultItem in result {
                if comparer(item, resultItem) {
                    continue outerLoop
                }
            }
            result.append(item)
        }
        return result
	}
	
	/**
	* A mapreduce aggregation function. The first closure maps the useful data, the second one reduces two items of the same type in one.
	*
	* @return the aggregated value or nil if the array is empty
	*/
	func mapReduce<R>(map: (T) -> R, reduce: (R, R) -> R) -> R? {
		return first.map {
			dropFirst(self).reduce(map($0)) {
				reduce($0, map($1))
			}
		}
	}
	
    /*
     * Groups items in this array by a key defined through the closure groupDefiner
     * 
     * @return a dictionary [R:[T]] that contains the groups as keys and the elements for each key as an array
     */
    func groupBy<R>(groupDefiner: T -> R) -> [R:[T]] {
        var result: [R: [T]] = [:]
        for item in self {
            if result[groupDefiner(item)] == nil {
                result[groupDefiner(item)] = []
            }
            result[groupDefiner(item)]!.append(item)
        }
        return result
    }
    
    /**
     * Filters the array by type
     * 
     * @return an array that contains only elements that are of type R, casted to type R
     */
    func ofType<R>(type: R.Type) -> [R] {
        var result: [R] = []
        for item in self {
            if item is R {
                result.append(item as! R)
            }
        }
        return result
	}
	
	/**
	* Joins the array with another array on a specific key, and then gives two matching elements to a closure to create a result type.
	*
	* @param otherArray the other array to join
	* @param thisKeyClosure the closure that extracts the key from this array
	* @param otherKeyClosure the closure that extracts the key from the other array
	* @param resultClosure creates a resulttype from two inputtypes
	*/
	func join<R, S: Equatable, P>(otherArray: [R], thisKeyClosure: T -> S, otherKeyClosure: R -> S, resultClosure: (T,R) -> P) -> [P] {
		var result: [P] = []
		for thisItem in self {
			for otherItem in otherArray {
				if thisKeyClosure(thisItem) == otherKeyClosure(otherItem) {
					result.append(resultClosure(thisItem, otherItem))
				}
			}
		}
		return result
	}
	
	/**
	* Joins the array with another array on a specific key, and then gives two matching elements to a closure to create a result type.
	* Groups the result by key.
	*
	* @param otherArray the other array to join
	* @param thisKeyClosure the closure that extracts the key from this array
	* @param otherKeyClosure the closure that extracts the key from the other array
	* @param resultClosure creates a resulttype from two inputtypes
	*/
	func groupJoin<R, S: Equatable, P>(otherArray: [R], thisKeyClosure: T -> S, otherKeyClosure: R -> S, resultClosure: (T,R) -> P) -> [S:[P]] {
		var result: [S:[P]] = [:]
		for thisItem in self {
			for otherItem in otherArray {
				let thisKey = thisKeyClosure(thisItem)
				if thisKey == otherKeyClosure(otherItem) {
					if result[thisKey] == nil {
						result[thisKey] = []
					}
					result[thisKey]!.append(resultClosure(thisItem, otherItem))
				}
			}
		}
		return result
	}
	
	/**
	 * Intersects this array with another, returning equal elements.
	 * Returning items from this array
	 */
	func intersect(otherArray: [T], comparer: Comparer) -> [T]{
		var result: [T] = []
		for item in self {
			for otherItem in otherArray {
				if comparer(item, otherItem) {
					result.append(item)
					break
				}
			}
		}
		return result
	}
	
	/**
	 * Selects items of interest from values in this array 
	 * Can be used with tuples like so: `array.select({item -> (Int, String) in (item.p1, item.p2)})` (type inference doesn't work in 1.2 yet)
	 */
	func select<R>(closure: T -> R) -> [R] {
		var result: [R] = []
		for item in self {
			result.append(closure(item))
		}
		return result
	}
	
	/**
	 * Skips the given amount of items, useful for paginating items
	 */
	func skip(value: Int) -> [T] {
		if value >= count {
			return []
		}
		if value <= 0 {
			return self
		}
		var result: [T] = []
		for var i = value; i < count; i += 1 {
			result.append(self[i])
		}
		return result
	}
	
	/**
	 * Takes the given amount of items from the beginning of the array
	 */
	func take(value: Int) -> [T] {
		if value >= count {
			return self
		}
		if value <= 0 {
			return []
		}
		var result: [T] = []
		for var i = 0; i < value; i += 1 {
			result.append(self[i])
		}
		return result
	}
	
	/**
	 * Takes the given amount of items from the end of the array
	 */
	func last(value: Int) -> [T] {
		return skip(count - value)
	}
	
	/**
	* Skips items in the array while the closure returns true, then returns the remaining items in the array
	*/
	func skipWhile(shouldContinue: T -> Bool) -> [T] {
		var result = count
		for (index, item) in enumerate(self) {
			if !shouldContinue(item) {
				return skip(index)
			}
		}
		return []
	}
	
	/**
	* Takes items in the array while the closure returns true, returns the array up to that index
	*/
	func takeWhile(shouldContinue: T -> Bool) -> [T] {
		var result = count
		for (index, item) in enumerate(self) {
			if !shouldContinue(item) {
				return take(index)
			}
		}
		return self
	}
	
	/**
	 * Merges the array with another array into a new array, using the given closure
	 * If both arrays are not the same length, the shortest one will be used
	 */
	func zip<R, Q>(otherArray: [R], zipClosure: (T, R) -> Q) -> [Q] {
		let maxIndex = count < otherArray.count ? count : otherArray.count
		var result: [Q] = []
		for var i = 0; i < maxIndex; i += 1 {
			result.append(zipClosure(self[i], otherArray[i]))
		}
		return result
	}
	
	/**
	 * Adds the elements of both this array and the other array, leaving out duplicate elements
	 */
	func Union(otherArray: [T], comparer: Comparer) -> [T] {
		var result: [T] = []
		result.extend(self)
		result.extend(otherArray)
		result.distinct(comparer)
		return result
	}
	
    // http://docs.mongodb.org/manual/core/aggregation-introduction/
    // http://www.oracle.com/technetwork/articles/java/ma14-java-se-8-streams-2177646.html
	
	// MARK: - Unfinished
	
	// Still need to check for lengths
	func tupleArrayWith<R>(otherArray: [R]) -> [(T, R)] {
		var result: [(T, R)] = []
		for (index, item) in enumerate(self) {
			result.append(item, otherArray[index])
		}
		return result
	}
	
	func average(closure: T -> Int) -> Int {
		var total: Int = 0
		for item in self {
			total += closure(item)
		}
		return total / count
	}
	
	func average(closure: T -> Double) -> Double {
		var total: Double = 0
		for item in self {
			total += closure(item)
		}
		return total / Double(count)
	}
	
	func average(closure: T -> Float) -> Float {
		var total: Float = 0
		for item in self {
			total += closure(item)
		}
		return total / Float(count)
	}
	
	// TODO: Sum
	// TODO: Min
	// TODO: Max
	
}