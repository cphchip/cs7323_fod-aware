//
//  SharedImageModel.swift
//  HTTPSwiftExample
//
//  Created by Wilma Davis on 12/10/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit

class SharedImageModel {
    static let sharedImages = SharedImageModel()
    var trayImages: [UIImage] = []

    private init() {} // Prevents other instances from being created
}
