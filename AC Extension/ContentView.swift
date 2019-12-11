//
//  ContentView.swift
//  AC Extension
//
//  Created by Bandu Wewalaarachchi on 4/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var service = Service()
    @State var zones: [Zone] = []
    @State var settingsMode: Int? = nil
    @State var showAlert: Bool = false

    var body: some View {
        NavigationView {
            List(zones, id: \.name) {
                zone in
                NavigationLink(destination: ZoneView(zone: zone)) {
                    HStack {
                        HStack {
                            Text(zone.name)
                            Spacer()
                            HStack {
                                if zone.status != .normal {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color(zone.statusColor()))
                                }
                                Text(String(format: "%2.0f:00 - %2.0f:00", zone.startHour, zone.endHour))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.init(.secondarySystemBackground))
                    .foregroundColor(Color.init(.label))
                        .cornerRadius(8)
                }
            }
            .navigationBarTitle(Text("AC Zones"))
            .alert(isPresented: $showAlert){
                Alert(title: Text("Service Error"), message: Text("Unable to fetch data. Settings may be incorrect"), primaryButton: .default(Text("Settings"), action: {
                    self.settingsMode = 1
                }), secondaryButton: .cancel(Text("OK")))
            }
            .navigationBarItems(leading:
            NavigationLink(destination: SettingsView(service: service), tag:1, selection: $settingsMode){
                Image(systemName: "gear").imageScale(.large)
            },trailing: Button(action: {
            self.fetchData()
        }, label: {
            Image(systemName: "icloud.and.arrow.down")
        }))
            .onAppear(){
                if self.service.url.isEmpty {
                    self.settingsMode = 1
                } else {
                    self.fetchData()
                }
            }
        }
    }
    
    init() {
        UITableView.appearance().separatorStyle = .none
    }
    
    func fetchData() {
        if service.zones.isEmpty {
            service.getZoneInfo(){
                success in
                if success {
                    self.service.getZoneData(){
                        success in
                        if success {
                            self.zones = []
                            self.zones = self.service.zones
                        }
                    }
                } else {
                    self.showAlert = true
                }
            }
        } else {
            self.service.getZoneData(){
                success in
                if success {
                    self.zones = []
                    self.zones = self.service.zones
                } else {
                    self.showAlert = true
                }
            }
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
