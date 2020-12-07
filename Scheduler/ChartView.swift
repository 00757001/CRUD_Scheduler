//
//  ChartView.swift
//  Scheduler
//
//  Created by User08 on 2020/12/3.
//

import SwiftUI
import SwiftUICharts

struct ChartView: View {
    @ObservedObject var scheduleData : ScheduleData
    @State private var selectedWeek = 1// barchart1,barchart2,piechart
    @State private var PredictMinCount = [0,0,0,0]
    @State private var PredictMinCount_done = [0,0,0,0]
    @State private var ActualMinCount = [0,0,0,0]
    @State private var timeSum = 0
    @State private var timeCompare = [0.0,0.0]
    @State private var percentage = 0.0 // matter done percentage
    @State private var dateString = [["",""],["",""]] //0 is last week
    let screen = UIScreen.main.bounds
    var body: some View {
        NavigationView{
            ScrollView(.vertical){
                VStack {
                    ScrollView(.horizontal) {
                        HStack(spacing:30) {
                            BarChartView(selectedWeek: $selectedWeek, MinCount: $PredictMinCount, dateString: $dateString, title: "Predicted Time Allocation")
                                .padding(.leading,10)
                            BarChartView(selectedWeek: $selectedWeek, MinCount: $ActualMinCount, dateString: $dateString, title: "Actual Time Allocation")
                                .padding(.trailing,15)
                        }
                    }
                    PieChartView(percentages: timeCompare, timeSum: timeSum, selectedWeek: $selectedWeek)
                    RingChartView(percentage: $percentage)
                }
            }
            .navigationTitle("Stats")
        }
        .onAppear{
            countWeeks()
            countPercentage()
            UISegmentedControl.appearance().selectedSegmentTintColor = .white
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        }
        .onChange(of: selectedWeek, perform: { value in
            countWeeks()
        })
    }
    func countWeeks(){
        //reset----------
        for i in 0..<types.count{
            PredictMinCount[i] = 0
            ActualMinCount[i] = 0
            PredictMinCount_done[i] = 0
        }
        timeCompare[0] = 0.0
        timeCompare[1] = 0.0
        //---------------
        if selectedWeek == 1{
            for i in 0..<scheduleData.schedule.count{
                if Calendar.current.isDate(Date(), equalTo: scheduleData.schedule[i].selectDate, toGranularity: .weekOfMonth){
                    PredictMinCount[scheduleData.schedule[i].type] += scheduleData.schedule[i].predictTime
                    
                    if scheduleData.schedule[i].isDone{
                        PredictMinCount_done[scheduleData.schedule[i].type] += scheduleData.schedule[i].predictTime
                        ActualMinCount[scheduleData.schedule[i].type] += scheduleData.schedule[i].actualTime!
                    }
                }
            }
            //after done
            countCompare()
        }
        else if selectedWeek == 0{
            let now = convertDateToLocalTime(Date())
            let Monday = convertDateToLocalTime(now.startOfWeek!)//this week start
            let Sunday = convertDateToLocalTime(now.endOfWeek!)//this week end
            let LastWeekStart = Monday.addingTimeInterval(-604800)
            let LastWeekEnd = Monday.addingTimeInterval(-86399)
            setDateString(lastWeekStart: LastWeekStart, lastWeekEnd: LastWeekEnd, thisWeekStart: Monday, thisWeekEnd: Sunday)
            print(LastWeekEnd)
            let range = LastWeekStart...Monday
            for i in 0..<scheduleData.schedule.count{
                if range.contains(scheduleData.schedule[i].selectDate){
                    PredictMinCount[scheduleData.schedule[i].type] += scheduleData.schedule[i].predictTime
                    if scheduleData.schedule[i].isDone{
                        PredictMinCount_done[scheduleData.schedule[i].type] += scheduleData.schedule[i].predictTime
                        ActualMinCount[scheduleData.schedule[i].type] += scheduleData.schedule[i].actualTime!
                    }
                }
            }
            //after done
          countCompare()
        }
    }
    
    func setDateString(lastWeekStart:Date,lastWeekEnd:Date,thisWeekStart:Date,thisWeekEnd:Date){
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        dateString[0][0] = formatter.string(from: lastWeekStart)
        dateString[0][1] = formatter.string(from: lastWeekEnd)
        dateString[1][0] = formatter.string(from: thisWeekStart)
        dateString[1][1] = formatter.string(from: thisWeekEnd)
    }
    
    func countPercentage(){
        percentage = 0.0
        var done : Double = 0
        var notDone : Double = 0
        for i in 0..<scheduleData.schedule.count{
            if(scheduleData.schedule[i].isDone){
                done += 1
            }
            else{
                notDone += 1
            }
        }
        if((done+notDone) > 0.0){
            percentage = done/(done+notDone)
            print(percentage)
        }
    }
    func countCompare(){
        let PredictSum = PredictMinCount_done.reduce(0, +)
        let ActualSum = ActualMinCount.reduce(0, +)
        timeSum = PredictSum + ActualSum
        if((PredictSum+ActualSum) > 0){
            let x = (Double(PredictSum) / Double(PredictSum+ActualSum)) * 100
            let y = (Double(ActualSum) / Double(PredictSum+ActualSum)) * 100
            timeCompare[0] = x
            timeCompare[1] = y
        }
    }
}



struct BarView : View{
    var time : Int
    var title : String
    var max : Int
    var sumTime : Int
    
    var body: some View{
        VStack{
            Text("\(time)")
                .font(.system(size: 20))
                .fontWeight(.medium)
                .frame(width:50)
            
            if time == max && sumTime > 0{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .frame(width:50, height:CGFloat(Double(time)/Double(sumTime))*90)
                    .animation(.default)
                    
            }
            else if sumTime > 0{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width:50, height:CGFloat(Double(time)/Double(sumTime))*90)
                    .animation(.default)
            }
            
            Text(title)
                .font(.system(size: 20))
                .fontWeight(.medium)
                .frame(width:50)
            
        }
    }
}



struct BarChartView: View {
    @Binding var selectedWeek : Int
    @Binding var MinCount : [Int]
    @Binding var dateString : [[String]]
    var title : String
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 25))
                .fontWeight(.heavy)
                .foregroundColor(.black)
            TimePicker(selectedWeek: $selectedWeek)
            VStack {
                Text("\(dateString[selectedWeek][0])~\(dateString[selectedWeek][1])")
                    .font(.system(size: 22))
                Spacer()
                HStack(alignment: .lastTextBaseline){
                    ForEach(0 ..< types.count) { i in
                        BarView(time: MinCount[i], title: types[i],max: MinCount.max()!,sumTime: MinCount.reduce(0, +))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.size.width * 0.8, height: 200)
            .cornerRadius(20)
            .shadow(radius: 20)
            .navigationTitle("Stats")
        }
        .modifier(StatsModifier())
        
    }
}


struct RingChartView: View {
    @Binding var percentage : Double
    var body: some View {
        VStack {
            Text("Schedule Complete Rate")
                .font(.system(size: 25))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .padding(.bottom,10)
            ZStack() {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.gray,style: StrokeStyle(lineWidth: 20, lineCap:.round))
                    .frame(width: 200, height: 200)
                if percentage <= 0.25{
                    Circle()
                        .trim(from: 0.0, to: CGFloat(percentage))
                        .stroke(Color.red,style: StrokeStyle(lineWidth: 20, lineCap:.round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(90))
                }
                else if percentage < 1.0{
                    Circle()
                        .trim(from: 0.0, to: CGFloat(percentage))
                        .stroke(Color.yellow,style: StrokeStyle(lineWidth: 20, lineCap:.round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(90))
                }
                else{
                    Circle()
                        .trim(from: 0.0, to: CGFloat(percentage))
                        .stroke(Color.green,style: StrokeStyle(lineWidth: 20, lineCap:.round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(90))
                    
                }
                VStack {
                    Text("\(percentage*100, specifier: "%.1f")%")
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                    Text("Completed")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
        }.modifier(StatsModifier())
    }
}

struct PieChart: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        Path { (path) in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            path.move(to: center)
            path.addArc(center: center, radius: 85,
     startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}

struct PieChartView: View {
    var percentages: [Double]
    var angles: [Angle]
    var timeSum : Int
    @Binding var selectedWeek : Int
    
    init(percentages:[Double],timeSum:Int,selectedWeek:Binding<Int>) {
        self.percentages = percentages
        self.timeSum = timeSum
        self._selectedWeek = selectedWeek
        angles = [Angle]()
        var startDegree : Double = 0
        for percentage in percentages {
            angles.append(.degrees(startDegree))
            startDegree += 360 * percentage / 100
        }
    }
    
    var body : some View{
        VStack {
            Text("Predicted vs Actual Time")
                .font(.system(size: 25))
                .fontWeight(.heavy)
                .foregroundColor(.black)
                .offset(y:10)
            TimePicker(selectedWeek: $selectedWeek)
            HStack {
                ZStack{
                    if percentages[0] == 0.0{
                        Circle()
                            .frame(width: 180, height:180)
                            .foregroundColor(.gray)
                        Text("None Finished")
                            .font(.system(size: 25))
                        
                    }
                    else{
                        Circle()
                            .frame(width: 200,height:200)
                            .foregroundColor(.white)
                    }
                    ForEach(angles.indices) { (i) in
                        if i == angles.count-1{
                            PieChart(startAngle: angles[i], endAngle: .zero).fill(Color(red: 244/255, green: 131/255, blue: 117/255))
                        } else{
                            PieChart(startAngle: angles[i], endAngle: angles[i+1]).fill(Color(red: 19/255, green: 121/255, blue: 169/255))
                        }
                    }
                    if percentages[0] != 0.0{
                        Circle()
                            .frame(width: 100, height:100)
                            .foregroundColor(.white)
                        Text("\(timeSum)min")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                    }
                }
                VStack {
                    Text("\(percentages[1],specifier: "%.1f")%")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .offset(x:-UIScreen.main.bounds.size.width * 0.18,y:-30)
                    VStack(alignment: .leading, spacing: 5){
                       
                        HStack {
                            Rectangle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(red: 244/255, green: 131/255, blue: 117/255))
                            Text("Actual")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Rectangle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(red: 19/255, green: 121/255, blue: 169/255))
                            Text("Predicted")
                                .fontWeight(.semibold)
                        }
                    }.offset(x:-UIScreen.main.bounds.size.width * 0.05,y:-8)
                    Text("\(percentages[0],specifier: "%.1f")%")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .offset(x:-UIScreen.main.bounds.size.width * 0.18,y:20)
                }
            }
        }.modifier(StatsModifier())
    }
}

struct StatsModifier : ViewModifier{

    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.main.bounds.size.width * 0.95, height: 300)
            .background(Color(red: 193/255, green: 239/255, blue: 247/255))
            .opacity(0.9)
            .cornerRadius(20)
    }
}

struct TimePicker : View{
    @Binding var selectedWeek : Int
    let selection = ["上週","本週"]
    var body: some View{
        VStack{
            Picker(selection: $selectedWeek, label: Text("")) {
                ForEach(selection.indices) { (i) in
                    Text(selection[i])
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width:300)
        }
    }
}

//-----------------------------Date extension
extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let startDay = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: startDay)
    }

    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
            guard let startDay = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
           return gregorian.date(byAdding: .day, value: 7, to: startDay)
       }
}

func convertDateToLocalTime(_ date: Date) -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date))
        return Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: date)!
}
