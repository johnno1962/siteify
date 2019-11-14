//
//  Parallelise.swift
//  siteify
//
//  Created by John Holdsworth on 30/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Parallelize.swift#4 $
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
