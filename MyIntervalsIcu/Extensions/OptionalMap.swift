//
//  OptionalMap.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/18/26.
//

import Foundation

extension Optional {

    func map<T>(_ transform: (Wrapped) throws -> T) rethrows -> T? {
        guard let wrapped = self else { return nil }
        return try transform(wrapped)
    }

}
