//
//  FuelFormViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 9/15/22.
//

import Foundation

class FuelFormViewModel: ObservableObject {
    typealias Dependencies = FormatterProvider
    
    var vehicleFuel: VehicleFuel
    
    @Published
    var date: Date = Date()
    
    @Published
    var fromOdo: String = ""
    
    @Published
    var toOdo: String = ""
    
    @Published
    var fuelAmount: String = ""
    
    var canSave: Bool {
        guard let fOdo = Int(fromOdo),
              let tOdo = Int(toOdo),
              let fuelAmt = Double(fuelAmount),
              tOdo > fOdo,
              fuelAmt > 0 else { return false }
        return true
    }
    
    var distance: Int {
        guard let fO = Int(fromOdo),
              let tO = Int(toOdo) else { return 0 }
        return tO - fO
    }
    
    var mpg: String {
        guard let fuelD = Double(fuelAmount),
              fuelD > 0 else { return "0.00"}
        
        return formatter.round2Str(Double(distance) / fuelD)
    }
    
    var asVehicleFuel: VehicleFuel {
        guard let fuelDate = date.withoutTime(),
              let fOdo = Int(fromOdo),
              let tOdo = Int(toOdo),
              let fAmt = Double(fuelAmount) else { fatalError() }
        
        let fDateStr = formatter.noTimeFormatter.string(from: fuelDate)
        
        vehicleFuel.fuel.date = fDateStr
        vehicleFuel.fuel.fromOdo = fOdo
        vehicleFuel.fuel.toOdo = tOdo
        vehicleFuel.fuel.distance = distance
        vehicleFuel.fuel.fuelAmount = fAmt

        return vehicleFuel
    }
    
    private let formatter: Formatter
    
    init(_ dependencies: Dependencies, vehicleFuel: VehicleFuel) {
        self.vehicleFuel = vehicleFuel
        formatter = dependencies.formatter
        
        date = vehicleFuel.date
        fromOdo = String(vehicleFuel.fuel.fromOdo)
        
        if vehicleFuel.fuel.toOdo > 0 {
            toOdo = String(vehicleFuel.fuel.toOdo)
        }
        
        if vehicleFuel.fuel.fuelAmount > 0 {
            fuelAmount = String(vehicleFuel.fuel.fuelAmount)
        }
    }
}
