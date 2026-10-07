//
//  ActivityDetailModule.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import FactoryKit

extension Container {
    
    var detailActivityIdSelector: Factory<Activity.ActivityId?> {
        self { nil }
    }
    
}
