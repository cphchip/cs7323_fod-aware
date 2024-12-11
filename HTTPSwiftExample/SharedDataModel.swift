//
//  SharedDataModel.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/10/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

class SharedDataModel {
    static let sharedData = SharedDataModel()
    var trayImages: [UIImage] = []

    private init() {} // Prevents other instances from being created
}
