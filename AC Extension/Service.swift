//
//  Service.swift
//  DeviceControl
//
//  Created by Bandu Wewalaarachchi on 23/10/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import Foundation
import SwiftUI

struct IvivaZoneInfo: Decodable {
    let ZoneName: String
    let ZoneKey: String
}

struct IvivaZoneData: Decodable {
    let ZoneKey: String
    let ZoneName: String
    let StartTime: String
    let EndTime: String
    let Status: String
    
    func getMinutes(dateString: String) -> Int {
        let hour = Int(String(dateString.dropFirst(11).prefix(2))) ?? 0
        let mins = Int(String(dateString.dropFirst(14).prefix(2))) ?? 0
        return (hour * 60 + mins)
    }
}

class Service: ObservableObject {
    @Published var zones: [[Zone]] = [[],[]]
//    @Published var tomorrowZones: [Zone] = []
    var url: String = ""
    var apiKey: String = ""
    
    init() {
        loadSettings()
        print("url \(url), apiKey \(apiKey)")
    }
    
    func executeAction(actionPath: String, body: Data?, _ completion: @escaping (Data?)->Void ){
        let session = URLSession.shared
        if let url = URL(string: url)?.appendingPathComponent(actionPath) {
            var request = URLRequest(url: url)
            request.setValue("APIKEY " + apiKey, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            if let body = body {
                request.httpBody = body
            }
            session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error != nil {
                    print(error!)
                }
                completion(data)
            }).resume()
        }
    }

    func fetchImage(path: String, _ completion: @escaping (UIImage?)->Void){
        let url = URL(fileURLWithPath: self.url).appendingPathComponent(path)
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let newImage = UIImage(data: data){
            DispatchQueue.main.async {
                completion(newImage)
            }
        } else {
            URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                var newImage: UIImage?
                if let data = data, let response = response {
                    if let image = UIImage(data: data) {
                        newImage = image
                        // set cache
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                    }
                }
                if let error = error {
                    print(error)
                }
                DispatchQueue.main.async {
                    completion(newImage)
                }
            }).resume()
        }
    }

    func fetchData() {
        getDataForDay(day: 0, apiPath: "OI/SP_ACExt_Tenant_API/GetDataForToday")
        getDataForDay(day: 1, apiPath: "OI/SP_ACExt_Tenant_API/GetDataForTomorrow")
    }
    
    public func getDataForDay(day: Int, apiPath: String){
        executeAction(actionPath: apiPath, body: nil){
            data in
            if let data = data {
                let decoder = JSONDecoder()
                if let results = try? decoder.decode([IvivaZoneData].self, from: data) {
                    DispatchQueue.main.async {
                        results.forEach(){
                            zData in
                            let date = String(zData.StartTime.prefix(10))
                            let startMins = zData.getMinutes(dateString: zData.StartTime)
                            let endMins = zData.getMinutes(dateString: zData.EndTime)
                            let status: Zone.Status = (zData.Status == "Requested" ? .requested : (zData.Status == "Scheduled" ? .scheduled : .normal))

                            if let zone = self.zones[day].first(where: { $0.ivivaKey == zData.ZoneKey}){
                                zone.date = date
                                zone.startMins = startMins
                                zone.endMins = endMins
                                zone.status = status
                            } else {
                                self.zones[day].append(Zone(service: self, name: zData.ZoneName, ivivaKey: zData.ZoneKey, status: status, date: date, startMins: startMins, endMins: endMins))
                            }
                        }
                        print("Data fetched for day \(day). Count = \(results.count)")
                    }
                }
            }
        }
    }
        
    public func createRequest(for zone: Zone, date: String, start: String, end: String, _ completion: @escaping (Bool)-> Void){
        let params: NSDictionary = ["ZoneKey": zone.ivivaKey, "Date": date, "Start": start, "End": end]
        if let body = try? JSONSerialization.data(withJSONObject: params, options: []) {
            executeAction(actionPath: "OI/SP_ACExt_Tenant_API/CreateRequest", body: body){
                data in
                if let data = data {
                    let decoder = JSONDecoder()
                    struct Result: Decodable {
                        var Success: String
                    }
                    if let result = try? decoder.decode(Result.self, from: data) {
                        DispatchQueue.main.async {
                            completion(!result.Success.isEmpty)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
    }
    
    
    public func saveSettings(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.first {
            let filename = path.appendingPathComponent("Settings.txt")
            let str = url + "," + apiKey
            do {
                try str.write(to: filename, atomically: true, encoding: .utf8)
            } catch {
                print("Unable to save settings")
            }
        }
    }
    
    private func loadSettings(){
        url = ""
        apiKey = ""
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.first {
            let filename = path.appendingPathComponent("Settings.txt")
            do {
                let str = try String(contentsOf: filename)
                let parts = str.components(separatedBy: ",")
                if parts.count == 2 {
                    url = parts[0]
                    apiKey = parts[1]
                }
            } catch {
                print("Unable to read settings")
            }
        }
    }
}
