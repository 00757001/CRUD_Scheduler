//
//  ScheduleData.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import Foundation
import SwiftUI

class ScheduleData: ObservableObject {
    @AppStorage("Schedule") var scheduleData: Data?
    
    @Published var schedule = [Matter](){
        didSet {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(schedule)
                scheduleData = data
            } catch {
                
            }
        }
    }
    
    init() {
        if let scheduleData = scheduleData {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Matter].self,from: scheduleData) {
                schedule = decodedData
            }
        }
    }
}
