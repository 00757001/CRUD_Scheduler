//
//  SchedulerList.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import SwiftUI
import UIKit

struct SchedulerList: View {
    @ObservedObject var scheduleData : ScheduleData
    @State private var showEditMatter = false
    @State private var date = Date()
    @State private var count = 0
    @State private var showSearchBar = false
    @State private var searchText = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationView{
            List{
                if !showSearchBar{
                    DatePicker("日期", selection: $date,displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .frame(maxHeight: 200)
                        .onChange(of: date, perform: { value in
                            count = 0
                            countEvent()
                    })
                    Text("\(count) Issues")
                        .fontWeight(.bold)
                        .font(.title)
                }
                else{
                    SearchBar(text: $searchText,isEditing: $isEditing)
                }
                
                ForEach(scheduleData.schedule.indices, id:\.self){(i) in
                    if !showSearchBar{
                        if Calendar.current.isDate(date, equalTo: scheduleData.schedule[i].selectDate, toGranularity: .day){
                                NavigationLink(destination: ScheduleEditor(editMatterIndex: i, scheduleData: scheduleData)){
                                    ScheduleRow(matter:scheduleData.schedule[i])
                                        
                            }
                        }
                    }
                    else{
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
                }
                .onMove { (indexSet, index) in
                    scheduleData.schedule.move(fromOffsets: indexSet,toOffset: index)
                }
                .onDelete { (indexSet) in
                    scheduleData.schedule.remove(atOffsets: indexSet)
                    count = 0
                    countEvent()
                }
                
            }
            .onAppear{
                count = 0
                countEvent()
            }
            .onChange(of: scheduleData.schedule.indices, perform: { value in
                count = 0
                countEvent()
            })
            .navigationBarTitle("Scheduling")
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        isEditing = false
                        searchText = ""
                        showSearchBar.toggle()
                        scheduleData.schedule = scheduleData.schedule.sorted(by: {
                            $0.selectDate.compare($1.selectDate) == .orderedAscending
                        })
                    },label:{
                        HStack{
                            Image(systemName:"magnifyingglass")
                            Text("Find")
                        }
                    })
                }
            })
            .sheet(isPresented:$showEditMatter){
                NavigationView {
                    ScheduleEditor(scheduleData:scheduleData)
                }
            }
        }
    }
    func countEvent(){
        for i in scheduleData.schedule.indices{
            if Calendar.current.isDate(date, equalTo: scheduleData.schedule[i].selectDate, toGranularity: .day){
                    count+=1
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isEditing:Bool
    var body: some View {
        HStack {
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }.overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
            }
        )
    }
    
}
