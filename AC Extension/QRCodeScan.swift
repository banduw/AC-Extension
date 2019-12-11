//
//  QRCodeScan.swift
//  DeviceControl
//
//  Created by Bandu Wewalaarachchi on 1/11/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct QRCodeScan: UIViewControllerRepresentable {
    let completion: (String)->Void
    @Environment(\.presentationMode) var presentation

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> QRCodeScanVC {
        let vc = QRCodeScanVC()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ vc: QRCodeScanVC, context: Context) {
    }

    class Coordinator: NSObject, QRCodeScannerDelegate {
        
        func codeDidFind(_ code: String) {
            DispatchQueue.main.async {
                self.parent.completion(code)
            }
            parent.presentation.wrappedValue.dismiss()
        }
        
        var parent: QRCodeScan
        
        init(_ parent: QRCodeScan) {
            self.parent = parent
        }
    }
}
