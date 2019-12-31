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
    
    var date: String
    @Published var startMins: Int
    @Published var endMins: Int
    @Published var status: Status

    init(service: Service, name: String, ivivaKey: String, status: Status = .normal, date: String, startMins: Int = 8 * 60, endMins: Int = 20 * 60) {
        self.service = service
        self.name = name
        self.ivivaKey = ivivaKey
        self.status = status
        self.date = date
        self.startMins = startMins
        self.endMins = endMins
    }
    
    func statusLabel() -> String {
        return(status == .requested ? "Request Pending":
        (status == .scheduled ? "Scheduled" : "Normal Schedule"))
    }
    
    func statusColor() -> UIColor {
        return (status == .requested ? UIColor.systemOrange:
            (status == .scheduled ? UIColor.systemGreen: UIColor.systemGray))
    }
        
    func getTimeString(for value: Int) -> String {
        let hour = value / 60
        let mins = value % 60
        let str = "\(hour < 10 ? "0":"")\(hour):\(mins < 10 ? "0":"")\(mins)"
        return str
    }
    
    func createRequest(start: Int, end: Int){
        service.createRequest(for: self, date: date, start: getTimeString(for: start), end: getTimeString(for: end)){
            success in
            self.status = .requested
            self.startMins = start
            self.endMins = end
        }
    }

}


