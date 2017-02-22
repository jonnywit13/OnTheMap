//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Jonathan Withams on 13/02/2017.
//  Copyright © 2017 Jonathan Withams. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
