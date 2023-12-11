//
//  PermissionManager.swift
//  QRCodeHelper
//
//  Created by o9tech on 11/12/2023.
//

import AVFoundation

struct PermissionManager {

    static func checkCameraPermission(completion: @escaping (Result<Void, PermissionError>) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    completion(.success(()))
                } else {
                    completion(.failure(.notGranted))
                }
            }
        }
    }
}
