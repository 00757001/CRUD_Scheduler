//
//  SchedulerList.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import SwiftUI
import UIKit

struct SchedulerAllList: View {
    @StateObject var scheduleData = ScheduleData()
    @State private var showEditMatter = false
    @State private var searchText = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationView{
            List{
                SearchBar(text: $searchText,isEditing: $isEditing)
                    
                ForEach(scheduleData.schedule.indices, id:\.self){(i) in
                    if isEditing{
                        if scheduleData.schedule[i].title.contains(searchText){
                            NavigationLink(destination: ScheduleEditor(editMatterIndex: i, scheduleData: scheduleData)){
                                ScheduleRow(matter:scheduleData.schedule[i])
                                    
                            }
                        }
                    }
                    else{
                        NavigationLink(destination: ScheduleEditor(editMatterIndex: i, scheduleData: scheduleData)){
                            ScheduleRow(matter:scheduleData.schedule[i])
                                
                        }
                    }
                }
                .onMove { (indexSet, index) in
                    scheduleData.schedule.move(fromOffsets: indexSet,toOffset: index)
                }
                .onDelete { (indexSet) in
                    scheduleData.schedule.remove(atOffsets: indexSet)
                }
            }
            .onAppear{
                scheduleData.schedule = scheduleData.schedule.sorted(by: {
                    $0.selectDate.compare($1.selectDate) == .orderedAscending
                })
                UITableView.appearance().separatorStyle = .none
            }
            .navigationBarTitle("事件列表")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                            showEditMatter = true
                        },
                        label: {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("New")
                            }.offset(x:-5)
                        })
                    }
                ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                }
            })
            .sheet(isPresented:$showEditMatter){
                NavigationView {
                    ScheduleEditor(scheduleData:scheduleData)
                }
            }
        }
    }
}
struct SchedulerAllList_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerAllList()
    }
}
