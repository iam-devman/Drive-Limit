//
//  SpeedViolationsView.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/5/23.
//

import SwiftUI
import CoreLocation
import MapKit




struct SpeedViolationsView: View {
    
    @StateObject var viewModel:MapDriveViewModel = MapDriveViewModel()
    
    var body: some View {
        NavigationView {
            List(allSpeedViolations) { violation in
                NavigationLink(destination: DetailView(speedingData: violation, region: violation.region)) {
                    ViolationRow(violation: violation)
                }
            }.navigationTitle("Speed Violations")
        }.onAppear {
            viewModel.updateData()
        }
    }
}



struct DetailView: View {
    let speedingData: SpeedViolation
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
    
    @State var locations: [Location] = [Location(id: UUID(), title: "Here", latitude: 0.0, longitude: 0.0)]
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: speedingData.latitude, longitude: speedingData.longitude))
            }.navigationTitle("Map View")
            
            Spacer()
            
            VStack {
                Text("Date: \(speedingData.date)")
                Text("Address: \(speedingData.address)")
                Text("Over \(String(speedingData.byWhat)) MPH")
                Text("Long: \(String(speedingData.longitude))")
                Text("Lat: \(String(speedingData.latitude))")
            }
            
            // ... other views to display more details
        }
    }
}

struct ViolationRow: View {
    var violation:SpeedViolation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(violation.convertDateToString()).font(.title2)
                Text(violation.address).font(.subheadline).foregroundColor(.secondary)

            }
            //.padding()
            Spacer()
        }
    }
}

struct SpeedViolationsView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedViolationsView()
    }
}
