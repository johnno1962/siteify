//
//  Parallelise.swift
//  siteify
//
//  Created by John Holdsworth on 30/10/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Parallelize.swift#1 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Foundation

public func parallelize(threads: Int,
                        name: String = "Parallelize",
                        work: () -> (() -> Void)?) {
    let concurrentQueue = DispatchQueue(label: name, attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: threads)
    let threadGroup = DispatchGroup()

    while let nextWork = work() {
        semaphore.wait()
        threadGroup.enter()

        concurrentQueue.async {
            nextWork()
            threadGroup.leave()
            semaphore.signal()
        }
    }

    threadGroup.wait()
}
