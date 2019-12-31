//
//  ZoneView.swift
//  AC Extension
//
//  Created by Bandu Wewalaarachchi on 4/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI

struct ZoneRowView: View {
    @ObservedObject var zone: Zone
    
    var body: some View {
        HStack {
            Text(zone.name)
            Spacer()
            HStack {
                Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(zone.statusColor()))
                Text("\(zone.getTimeString(for: zone.startMins)) - \(zone.getTimeString(for: zone.endMins))")
            }
        }
        .padding()
        .background(Color.init(.secondarySystemBackground))
        .foregroundColor(Color.init(.label))
        .cornerRadius(8)
    }
}


struct ZoneView: View {
    var zone: Zone
    @Environment(\.presentationMode) var presentation
    @State var edited = false
    @State var startMins: Float = 0
    @State var endMins: Float = 0

    var body: some View {
        VStack {
            HStack {
                Text(zone.statusLabel())
                    .padding(10)
                    .background(Color.init(zone.statusColor()))
                    .cornerRadius(16)
                    .foregroundColor(Color.init(.secondarySystemBackground))
                Spacer()
            }
            .padding(.bottom, 30)
            
            HStack {
                Text("Start Time")
                Spacer()
                Text(self.zone.getTimeString(for: Int(startMins.rounded())))
            }
            Slider(value: $startMins, in: 300...480, step: 30, onEditingChanged: {
                isStart in
                if !isStart {
                    self.edited = true
                }
            })
            .padding(.bottom, 20)

            HStack {
                Text("End Time")
                Spacer()
                Text(zone.getTimeString(for: Int(endMins.rounded())))
            }
            Slider(value: $endMins, in: 120...1440, step: 30, onEditingChanged: {
                isStart in
                if !isStart {
                    self.edited = true
                }
            })
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text(zone.name))
        .navigationBarItems(trailing: Button(action: {
            self.zone.createRequest(start: Int(self.startMins.rounded()), end: Int(self.endMins.rounded()))
            self.presentation.wrappedValue.dismiss()
        }) {
            Text("Request")
        }
        .disabled(!edited))
        .onAppear(){
            self.startMins = Float(self.zone.startMins)
            self.endMins = Float(self.zone.endMins)
        }
    }
}

