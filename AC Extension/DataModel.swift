//
//  DataModel.swift
//  AC Extension
//
//  Created by Bandu Wewalaarachchi on 6/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import Foundation
import UIKit

class Zone: ObservableObject {
    enum Status: String {
        case normal, requested, scheduled
    }
    weak var service: Service!
    let ivivaKey: String
    let name: String
    
    @Published var startHour: Float = 8
    @Published var endHour: Float = 20
    @Published var status: Status = .normal

    init(service: Service, name: String, ivivaKey: String, status: Status = .normal) {
        self.service = service
        self.name = name
        self.ivivaKey = ivivaKey
        self.status = status
    }
    
    func statusLabel() -> String {
        return(status == .requested ? "Request Pending":
        (status == .scheduled ? "Scheduled" : "Normal Schedule"))
    }
    
    func statusColor() -> UIColor {
        return (status == .requested ? UIColor.systemOrange:
            (status == .scheduled ? UIColor.systemGreen: UIColor.systemGray))
    }
    
    func requestSchedule() -> Void {
        status = .requested
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.status = .scheduled
        })
    }

    func withdraw() -> Void {
        status = .requested
        startHour = 8
        endHour = 20
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.status = .normal
        })
    }
}


