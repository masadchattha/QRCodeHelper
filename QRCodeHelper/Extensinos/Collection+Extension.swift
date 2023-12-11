//
//  Extension+Collection.swift
//  QRCodeHelper
//
//  Created by Muhammad Asad Chattha on 09/12/2023.
//

import Foundation

extension Collection {

    /// A computed property indicating whether the string is not empty.
    ///
    /// This property returns `true` if the string is not empty and `false` otherwise.
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}
