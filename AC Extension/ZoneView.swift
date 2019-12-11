//
//  ZoneView.swift
//  AC Extension
//
//  Created by Bandu Wewalaarachchi on 4/12/19.
//  Copyright © 2019 Bandu Wewalaarachchi. All rights reserved.
//

import SwiftUI
//import UIKit

struct ZoneView: View {
    @ObservedObject var zone: Zone
    @Environment(\.presentationMode) var presentation
    @State var edited = false

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
                Text(String(format: "%2.0f:00", Double(self.zone.startHour)))
            }
            Slider(value: $zone.startHour, in: 5...8, step: 1, onEditingChanged: {
                isStart in
                if !isStart {
                    self.edited = true
                }
            })
            .padding(.bottom, 20)
            .disabled(self.zone.status == .scheduled)

            HStack {
                Text("End Time")
                Spacer()
                Text(String(format: "%2.0f:00", Double(zone.endHour)))
            }
            Slider(value: $zone.endHour, in: 20...24, step: 1, onEditingChanged: {
                isStart in
                if !isStart {
                    self.edited = true
                }
            })
            .disabled(self.zone.status == .scheduled)
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text(zone.name))
        .navigationBarItems(trailing: Button(action: {
            if self.zone.status != .scheduled {
                self.zone.requestSchedule()
            } else {
                self.zone.withdraw()
            }
            self.presentation.wrappedValue.dismiss()
        }) {
            Text(self.zone.status != .scheduled ? "Request": "Withdraw")
        }
        .disabled(!edited))
        .onAppear(){
            self.edited = (self.zone.status == .scheduled)
        }
    }
}

