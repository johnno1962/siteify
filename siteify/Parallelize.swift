//
//  Parallelise.swift
//  siteify
//
//  Created by John Holdsworth on 30/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Parallelize.swift#7 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

extension Sequence {

    @discardableResult
    func concurrentMap<Output>(maxConcurrency: Int = 4,
                               queueName: String = "concurrentMap",
                               priority: DispatchQoS = .default,
                               worker: @escaping (Element,
                            @escaping (Output) -> Void) -> Void) -> [Output] {
        let input = Array(self)
        var output = Array<Output>(unsafeUninitializedCapacity: input.count,
                                   initializingWith: {
                                    (buffer, initializedCount) in
                                    let stride = MemoryLayout<Output>.stride
                                    memset(buffer.baseAddress, 0,
                                           stride * input.count)
                                    initializedCount = input.count})

        output.withUnsafeMutableBufferPointer {
            buffer in
            let buffro = buffer
            let concurrentQueue = DispatchQueue(label: queueName, qos: priority,
                                                attributes: .concurrent)
            let semaphore = DispatchSemaphore(value: maxConcurrency)
            let threadGroup = DispatchGroup()

            for index in 0..<input.count {
                threadGroup.enter()
                semaphore.wait()

                concurrentQueue.async {
                    worker(input[index], { result in
                        buffro[index] = result
                        threadGroup.leave()
                        semaphore.signal()
                    })
                }
            }

            threadGroup.wait()
        }

        return output
    }
}

extension NSLock {

    public func synchronized<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
}

/// Wrapper for os_unfair_lock mutex primitve from the
/// project: https://github.com/Alamofire/Alamofire
@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public final class UnfairLock {
    private let unfairLock: os_unfair_lock_t

    public init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    private func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    private func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

    /// Executes a closure returning a value while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    ///
    /// - Returns:           The value the closure generated.
    func synchronized<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }

    /// Execute a closure while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    func synchronized(_ closure: () -> Void) {
        lock(); defer { unlock() }
        return closure()
    }
}

public typealias SynchronizableLock = UnfairLock
private var allLocks = [OpaquePointer: SynchronizableLock]()
private var lockLock = SynchronizableLock()

protocol Synchronizable {
    mutating func synchronized<T>(_ closure: (inout Self) -> T) -> T
}

extension Dictionary: Synchronizable {}
extension Array: Synchronizable {}
extension Int: Synchronizable {}

extension Synchronizable {

    public mutating func synchronized<T>(_ closure: (inout Self) -> T) -> T {
        let lockee = UnsafeMutablePointer(&self)
        let lock = lockLock.synchronized { () -> SynchronizableLock in
            let key = OpaquePointer(lockee)
            var lock = allLocks[key]
            if lock == nil {
                lock = SynchronizableLock()
                allLocks[key] = lock
            }
            return lock!
        }
        return lock.synchronized { closure(&lockee.pointee) }
    }

    public mutating func desynchronize() {
        let lockee = UnsafeMutablePointer(&self)
        lockLock.synchronized {
            allLocks[OpaquePointer(lockee)] = nil
        }
    }
}

//extension Synchronizable where Self: AnyObject {
//
//    public mutating func synchronized<T>(_ closure: (inout Self) -> T) -> T {
//        let lockee = Unmanaged.passUnretained(self).toOpaque()
//        let lock = lockLock.synchronized { () -> SynchronizableLock in
//            let key = OpaquePointer(lockee)
//            var lock = allLocks[key]
//            if lock == nil {
//                lock = SynchronizableLock()
//                allLocks[key] = lock
//            }
//            return lock!
//        }
//        return lock.synchronized { closure(&self) }
//    }
//
//    public mutating func desynchronize() {
//        let lockee = Unmanaged.passUnretained(self).toOpaque()
//        lockLock.synchronized {
//            allLocks[OpaquePointer(lockee)] = nil
//        }
//    }
//}
