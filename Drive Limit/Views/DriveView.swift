//
//  DriveView.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/2/23.
//

import SwiftUI
import MapKit

struct DriveView: View {
    
    @StateObject var viewModel:MapDriveViewModel = MapDriveViewModel() // contains the values we need for this view
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("Drive Limit")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer(minLength: 10)
                Map(coordinateRegion: self.$viewModel.region,
                    showsUserLocation: true,userTrackingMode: .constant(.follow))
                
                Spacer(minLength: 10)
                VStack(alignment: .leading){
                    Text(self.viewModel.currentSpeedText ?? "Getting Speed")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .bold()
                        .padding()
                    Text(self.viewModel.currentAddress ?? "Getting Address")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    Text(viewModel.currentSpeedLimitText ?? "Getting Speed Limit of Road")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    Spacer(minLength: 10)
                }
            }.padding()
                .onDisappear(perform: viewModel.stopTimer)
                .onAppear(perform: viewModel.startTimer)
        }
    }
}

struct DriveView_Previews: PreviewProvider {
    static var previews: some View {
        DriveView()
    }
}
