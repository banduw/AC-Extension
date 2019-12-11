//
//  Service.swift
//  DeviceControl
//
//  Created by Bandu Wewalaarachchi on 23/10/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import Foundation
import UIKit

struct IvivaZoneInfo: Decodable {
    let ZoneName: String
    let ZoneKey: String
}

struct IvivaZoneData: Decodable {
    let ZoneKey: String
    let StartTime: String
    let EndTime: String
    let Status: String
}

class Service: ObservableObject {
    @Published var zones: [Zone] = []
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

        
    public func getZoneInfo(_ completion: @escaping (Bool) -> Void) {
        executeAction(actionPath: "OI/SP_ACExt_Tenant_API/GetZoneInfo", body: nil){
            data in
            if let data = data {
                let decoder = JSONDecoder()
                if let results = try? decoder.decode([IvivaZoneInfo].self, from: data) {
                    DispatchQueue.main.async {
                        results.forEach(){
                            bData in
                            self.zones.append( Zone(service: self, name: bData.ZoneName, ivivaKey: bData.ZoneKey))
                        }
                        completion(!self.zones.isEmpty)
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
    
    public func getZoneData(_ completion: @escaping (Bool)-> Void){
        executeAction(actionPath: "OI/SP_ACExt_Tenant_API/GetZoneData", body: nil){
            data in
            if let data = data {
                let decoder = JSONDecoder()
                if let results = try? decoder.decode([IvivaZoneData].self, from: data) {
                    DispatchQueue.main.async {
                        var updated = false
                        results.forEach(){
                            zData in
                            if let zone = self.zones.first(where: { $0.ivivaKey == zData.ZoneKey}){
                                zone.startHour = (zData.StartTime as NSString).floatValue
                                zone.endHour = (zData.EndTime as NSString).floatValue
                                zone.status = (zData.Status == "Requested" ? .requested : (zData.Status == "Scheduled" ? .scheduled : .normal))
                                updated = true
                            }
                        }
                        completion(updated)
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
         
    /*public func getValues(for device: Device, _ completion: @escaping ([DevicePoint]?)-> Void){
        let params: NSDictionary = ["DeviceID": device.name]
        let pTypes = pointTypes.filter({$0.DeviceType == device.type})
        if !pTypes.isEmpty, let body = try? JSONSerialization.data(withJSONObject: params, options: []) {
            executeAction(actionPath: "OI/SBIM_RemoteEx_API/GetData", body: body){
                data in
                if let data = data {
                    let decoder = JSONDecoder()
                    if let results = try? decoder.decode([String: String].self, from: data) {
                        DispatchQueue.main.async {
                            var points: [DevicePoint] = []
                            pTypes.forEach(){
                                pType in
                                if let pData = results[pType.PointName] {
                                    points.append(DevicePoint(service: self, device: device, label: pType.Label, pointName: pType.PointName, value: pData, display: pType.Display, options: pType.Options))
                                }
                            }
                            completion(points)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }

    public func setValue(update point: DevicePoint, with newValue: String, _ completion: @escaping (Bool)-> Void){
        let params: NSDictionary = ["DeviceID": point.device.name, "PointName": point.pointName, "PointValue": newValue]
        if let body = try? JSONSerialization.data(withJSONObject: params, options: []) {
            executeAction(actionPath: "OI/SBIM_RemoteEx_API/UpdatePoint", body: body){
                data in
                if let data = data {
                    let decoder = JSONDecoder()
                    struct Result: Decodable {
                        var Success: Bool
                    }
                    if let result = try? decoder.decode(Result.self, from: data) {
                        DispatchQueue.main.async {
                            completion(result.Success)
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
    }*/
    
    
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
