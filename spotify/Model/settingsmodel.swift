//
//  settingsmodel.swift
//  spotify
//
//  Created by Purv Sinojiya on 19/02/25.
//

import Foundation
struct Section {
    let title:String
    let options:[Option]
}
struct Option {
    let title: String
    let handler: () -> Void
}
