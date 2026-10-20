//
//  PublisherSinkExtension.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Combine

extension Publisher where Failure == Error {

    func sink(
        onError: @escaping (Failure) -> Void,
        onReceieveValue: ((Output) -> Void)? = nil,
    ) -> AnyCancellable {
        sink { completion in
            guard let error = completion.error else { return }
            onError(error)
        } receiveValue: { onReceieveValue?($0) }

    }

}
