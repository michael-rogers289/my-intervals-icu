//
//  ViewLoggingDependencyModule.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import FactoryKit

extension Container {

    var viewLogger: Factory<ViewLogging> {
        self {
            ViewLogger()
        }
    }
}
