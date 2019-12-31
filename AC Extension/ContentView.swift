//
//  ContentView.swift
//  AC Extension
//
//  Created by Bandu Wewalaarachchi on 4/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var service = Service()
    @State var settingsMode: Int? = nil
    @State var showAlert: Bool = false

    var body: some View {
        NavigationView {
            TabView {
                List(service.zones[0], id: \.ivivaKey) {
                    zone in
                    NavigationLink(destination: ZoneView(zone: zone)) {
                        ZoneRowView(zone: zone)
                    }
                }
                .tabItem {
                    Image(systemName: "clock")
                    Text("Today")
                }
                List(service.zones[1], id: \.ivivaKey) {
                    zone in
                    NavigationLink(destination: ZoneView(zone: zone)) {
                        ZoneRowView(zone: zone)
                    }
                }
                .tabItem {
                    Image(systemName: "clock")
                    Text("Tomorrow")
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
                self.service.fetchData()
            }, label: {
                Image(systemName: "icloud.and.arrow.down")
            }))
        }
        .onAppear(){
            if self.service.url.isEmpty {
                self.settingsMode = 1
            } else {
                self.service.fetchData()
            }
        }
    }
    
    init() {
        UITableView.appearance().separatorStyle = .none
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

