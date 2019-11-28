//
//  Synchronizer.swift
//  siteify
//
//  Created by John Holdsworth on 28/11/2019.
//  Copyright © 2019 John Holdsworth. All rights reserved.
//
//  $Id: //depot/siteify/siteify/Synchronizer.swift#1 $
//
//  Repo: https://github.com/johnno1962/siteify
//

import Dispatch
import SwiftLSPClient

struct LanguageServerSynchronizer {
    let semaphore = DispatchSemaphore(value: 0)
    var errorHandler = {
        (message: String) in
        fatalError(message)
    }

    func sync(_ block: @escaping (@escaping (LanguageServerError?) -> Void) -> Void) {
        block({ (error: LanguageServerError?) in
            if error != nil {
                self.errorHandler("LanguageServerError: \(error!)")
            }
            self.semaphore.signal()
        })
        semaphore.wait()
    }

    func sync<RESP>(_ block: @escaping (@escaping (LanguageServerResult<RESP>) -> Void) -> Void) -> RESP {
        var theResponse: RESP?
        block({ (response: LanguageServerResult) in
            switch response {
            case .success(let value):
                theResponse = value
            case .failure(let error):
                self.errorHandler("Error response \(error)")
            }
            self.semaphore.signal()
        })
        semaphore.wait()
        return theResponse!
    }
}

