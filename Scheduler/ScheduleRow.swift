//
//  ScheduleRow.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import SwiftUI

struct ScheduleRow: View {
    var matter : Matter
    @State var showDate = true
    @State var timeString = ""
    @State var dateString = ""
    var body: some View {
        HStack{
            VStack {
                Text(matter.title)
                    .fontWeight(.bold)
                    .font(.system(size: 30))
                    .padding(8)
                    .padding(.leading,10)
                    .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                    .offset(x:-15)
                    .minimumScaleFactor(0.5)
                    
                HStack{
                    if matter.isDone{
                        Group {
                            Image(systemName: "stopwatch")
                                .scaleEffect(1.4)
                                
                            Text("\(matter.predictTime)min")
                                .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                                .minimumScaleFactor(0.5)
                                .scaledToFit()
                            Image(systemName: "checkmark.circle")
                                .scaleEffect(1.4)
                                
                            Text("\(matter.actualTime!)min")
                                .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                                .minimumScaleFactor(0.5)
                                .scaledToFit()
                        }
                    }
                    else{
                        Group {
                            Image(systemName: "stopwatch")
                                .scaleEffect(1.4)
                            Text("\(matter.predictTime)min")
                                .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                                .minimumScaleFactor(0.5)
                                .scaledToFit()
                        }
                        
                    }
                }
                Text(dateString)
                    .font(.title3)
                    .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                    .frame(height:40)
            }
            VStack {
                Text(timeString)
                    .font(.title3)
                    .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height:40)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.black, lineWidth: 2))
                    Text(types[matter.type])
                        .fontWeight(.semibold)
                        .font(.title2)
                        .foregroundColor(Color(UIColor(hexString:matter.colorHex)))
                }.frame(width:100)
                    
            }.minimumScaleFactor(0.5)
        }
        .onAppear{
            setDateString()
        }
        .frame(height: 120)
        .padding(.leading,5)
        .padding(.trailing,5)
        .background(Color(UIColor(hexString:matter.colorHex ).withAlphaComponent(CGFloat(matter.colorAlpha))))
        .cornerRadius(15)
        
    }
    func setDateString(){
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .short
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .short
        timeString = formatter1.string(from: matter.selectDate)
        dateString = formatter2.string(from: matter.selectDate)
    }
}

struct ScheduleRow_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleRow(matter: Matter(title: "資料庫專案", type: 0, predictTime: 60, actualTime:120, isDone: false,colorHex:"f3f0f",colorAlpha: 0.5,selectDate:Date()))
            .previewLayout(.sizeThatFits)
    }
}
