//
//  SettingsView.swift
//  DeviceControl
//
//  Created by Bandu Wewalaarachchi on 26/10/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var service: Service
    @Environment(\.presentationMode) var presentation
    
    @State var url: String = ""
    @State var apiKey: String = ""
    
    var body: some View {
        Form {
            TextField("Account URL", text: $url)
                .autocapitalization(.none)
            TextField("ApiKey", text: $apiKey)
                .autocapitalization(.none)
            Divider()
            HStack(alignment: .center) {
                Spacer()
                Text(getVersion()).font(.caption)
                Spacer()
            }
        }
        .navigationBarTitle(Text("Settings"))
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: QRCodeScan(completion: {
                code in
                self.extractAccountInfo(from: code)
            })) {
                Image(systemName: "qrcode").imageScale(.large)
            }.padding(.trailing, 20)
            Button("Save"){
                self.service.zones = []
                self.service.url = self.url
                self.service.apiKey = self.apiKey
                self.service.saveSettings()
                self.presentation.wrappedValue.dismiss()
            }
        })
        .onAppear(){
            self.url = self.service.url
            self.apiKey = self.service.apiKey
        }
    }
    
    private func extractAccountInfo(from urlStr: String) {
        let keyPattern = "apikey=SC:[\\w:]+"
        let hostPattern = "://.+?/"
        if let hostRange = urlStr.range(of: hostPattern, options: [.regularExpression, .caseInsensitive]), let keyRange = urlStr.range(of: keyPattern, options: [.regularExpression, .caseInsensitive]) {
            let host = urlStr[hostRange].trimmingCharacters(in: CharacterSet(charactersIn: ":/"))
            let locKey = urlStr[keyRange].dropFirst(7)
            self.url = "https://\(host)"
            self.apiKey = String(locKey)
        }
    }
    
    private func getVersion() -> String {
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.0"
        let build = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "0"
        return "Version \(version) (\(build))"
    }
}

