//
//  ContentView.swift
//  Scheduler
//
//  Created by HungJie on 2020/11/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var scheduleData = ScheduleData()
    var body: some View {
        ZStack {
            TabView(){
                SchedulerList(scheduleData: scheduleData)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("日程")
                    }
                
                ChartView(scheduleData: scheduleData)
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("數據統計")
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
