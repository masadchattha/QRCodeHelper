//
//  Instantiable.swift
//  QRCodeHelper
//
//  Make Controllers easy to instantiate by calling just instantiateFromStoryboardHelper
//
//
//  Created by Muhammad Asad Chattha on 10/12/2023.
//

import UIKit

protocol Instantiable {
    static var storyboard: UIStoryboard { get }
}

// MARK: - Providing default implementation
extension Instantiable {

    static func instantiate() -> Self {
        return instantiateFromStoryboard()
    }

    private static func instantiateFromStoryboard<T>() -> T {
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}
