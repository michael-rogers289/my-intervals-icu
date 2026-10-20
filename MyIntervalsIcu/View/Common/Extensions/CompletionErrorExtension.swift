//
//  CompletionErrorExtension.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Combine

extension Subscribers.Completion {

    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

}
