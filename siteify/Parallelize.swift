//
//  Parallelise.swift
//  siteify
//
//  Created by John Holdsworth on 30/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Parallelize.swift#3 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

extension Sequence {

    @discardableResult
    func concurrentMap<Output>(maxConcurrency: Int,
                       queueName: String = "concurrentMap2",
                    priority: DispatchQoS = .default,
                    worker: @escaping (Element, @escaping (Output) -> Void) -> Void) -> [Output] {
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
            let buff = buffer
            let concurrentQueue = DispatchQueue(label: queueName, qos: priority,
                                                attributes: .concurrent)
            let semaphore = DispatchSemaphore(value: maxConcurrency)
            let threadGroup = DispatchGroup()

            for index in 0..<input.count {
                threadGroup.enter()
                semaphore.wait()

                concurrentQueue.async {
                    worker(input[index], { result in
                        buff[index] = result
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

//extension DispatchGroup {
//
//    public static func parallelize(threads: Int,
//                            name: String = "Parallelize",
//                            priority: DispatchQoS = .default,
//                            workProvider: () -> (() -> Void)?) {
//        let concurrentQueue = DispatchQueue(label: name, qos: priority, attributes: .concurrent)
//        let semaphore = DispatchSemaphore(value: threads)
//        let threadGroup = DispatchGroup()
//
//        while let nextWork = workProvider() {
//            semaphore.wait()
//            threadGroup.enter()
//
//            concurrentQueue.async {
//                nextWork()
//                threadGroup.leave()
//                semaphore.signal()
//            }
//        }
//
//        threadGroup.wait()
//    }
//
//    static func forEach<Seq: Sequence>(in sequence: Seq,
//                 maxConcurrency: Int,
//                 queueName: String = "concurrentEach",
//                 priority: DispatchQoS = .default,
//                 worker: @escaping (Seq.Element) -> Void) {
//        let concurrentQueue = DispatchQueue(label: queueName, qos: priority, attributes: .concurrent)
//        let semaphore = DispatchSemaphore(value: maxConcurrency)
//        let threadGroup = DispatchGroup()
//        var iterator = sequence.makeIterator()
//
//        while let next = iterator.next() {
//            semaphore.wait()
//            threadGroup.enter()
//
//            concurrentQueue.async {
//                worker(next)
//                threadGroup.leave()
//                semaphore.signal()
//            }
//        }
//
//        threadGroup.wait()
//    }
//}
//
//extension Sequence {
//
//    @discardableResult
//    func concurrentMap<Output>(queueName: String = "concurrentMap",
//                 priority: DispatchQoS = .default,
//                 worker: @escaping (Element) -> Output) -> [Output] {
//        let input = Array(self)
//        var output = Array<Output>(unsafeUninitializedCapacity: input.count,
//                                   initializingWith: {
//                                    (buffer, initializedCount) in
//                                    let stride = MemoryLayout<Output>.stride
//                                    memset(buffer.baseAddress, 0,
//                                           stride * buffer.count)
//                                    initializedCount = buffer.count})
//        let concurrentQueue = DispatchQueue(label: queueName, qos: priority,
//                                            attributes: .concurrent)
//
//        concurrentQueue.sync {
//            output.withUnsafeMutableBufferPointer {
//                buffer in
//                DispatchQueue.concurrentPerform(iterations: input.count) {
//                    index in
//                    buffer.baseAddress![index] = worker(input[index])
//                }
//            }
//        }
//
//        return output
//    }
//
//    func forEach(maxConcurrency: Int,
//                 queueName: String = "concurrentEach",
//                 priority: DispatchQoS = .default,
//                 worker: @escaping (Element) -> Void) {
//        DispatchGroup.forEach(in: self,
//                              maxConcurrency: maxConcurrency,
//                              queueName: queueName,
//                              priority: priority,
//                              worker: worker)
//    }
//}
//
//extension NSLock {
//    func synchronize<V>(block: () -> V) -> V {
//        lock()
//        let value = block()
//        unlock()
//        return value
//    }
//}
//
//#if true
//private class OSLock {
//
//    private var _lockPtr: os_unfair_lock_t
//
//    init() {
//        _lockPtr = .allocate(capacity: 1)
//        _lockPtr.initialize(to: os_unfair_lock())
//    }
//
//    func synchronize<V>(block: () -> V) -> V {
//        os_unfair_lock_lock(_lockPtr)
//        defer { os_unfair_lock_unlock(_lockPtr) }
//        return block()
//    }
//
//    deinit {
//        _lockPtr.deinitialize(count: 1)
//        _lockPtr.deallocate()
//    }
//}
//#else
//private class OSLock {
//
//    private var _lockPtr: UnsafeMutablePointer<pthread_mutex_t>
//
//    init() {
//        _lockPtr = .allocate(capacity: 1)
//        pthread_mutex_init(_lockPtr, nil)
//    }
//
//    func synchronize<V>(block: () -> V) -> V {
//        pthread_mutex_lock(_lockPtr)
//        let value = block()
//        pthread_mutex_unlock(_lockPtr)
//        return value
//    }
//
//    deinit {
//        _lockPtr.deinitialize(count: 1)
//        _lockPtr.deallocate()
//    }
//}
//#endif
