//
//  ParkBenchTimer.swift
//  FelineFinder
//
//  Created by Gregory Williams on 3/12/21.
//

import Foundation

class SearchTimer {

    var startTime:CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    func duration() -> CFAbsoluteTime? {
        if let startTime = startTime {
            return CFAbsoluteTimeGetCurrent() - startTime
        } else {
            return nil
        }
    }
}
