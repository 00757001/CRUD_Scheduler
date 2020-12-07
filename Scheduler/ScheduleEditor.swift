//
//  ScheduleEditor.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import SwiftUI

struct ScheduleEditor: View {
    @Environment(\.presentationMode) var presentationMode
    var editMatterIndex : Int?
    @State private var title = ""
    @State private var type = 0
    @State private var predictTime = 0
    @State private var actualTime = 0
    @State private var isDone = false
    @State private var bgColor = Color.red
    @State private var colorHex = "FF0000"
    @State private var colorAlpha = 0.5
    @State private var selectDate = Date()
    @State private var showAlert = false
    
    var scheduleData : ScheduleData
    
    var body: some View {
        Form{
            TextField("標題",text: $title)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 50).stroke(bgColor, lineWidth: 5))
                .padding()
            VStack {
                ColorPicker("自訂事件顏色", selection: $bgColor).font(.title2)
                    .onChange(of: bgColor){ newValue in
                        let temp = UIColor(bgColor)
                        colorHex = temp.toHexString()
                        if temp.toAlpha() >= 0.5{
                            colorAlpha = 0.5
                        }
                        else{
                            colorAlpha = Double(temp.toAlpha())
                        }
                        print(colorAlpha)
                    }
                    
            }
            VStack {
                TypePicker(type: $type)
            }
            VStack {
                DatePicker("選擇日期", selection: $selectDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 340)
            }
            
            
            Stepper("預計完成時間 \(predictTime)分鐘", value: $predictTime, in: 0...300,step:15).font(.title2)
            Toggle("完成", isOn: $isDone).font(.title2)
            if isDone{
                Stepper("實際完成時間 \(actualTime)分鐘", value: $actualTime, in: 0...300,step:15).font(.title2)
            }
        }
        .onAppear(perform: {
            if let editMatterIndex = editMatterIndex {
                let editSchedule = scheduleData.schedule[editMatterIndex]
                title = editSchedule.title
                type = editSchedule.type
                predictTime = editSchedule.predictTime
                actualTime = editSchedule.actualTime!
                isDone = editSchedule.isDone
                colorHex = editSchedule.colorHex
                colorAlpha = Double(editSchedule.colorAlpha)
                let tempColor = UIColor(hexString:editSchedule.colorHex ).withAlphaComponent(CGFloat(editSchedule.colorAlpha))
                bgColor = Color(tempColor)
                selectDate = editSchedule.selectDate
            }
        })
        .navigationBarTitle(editMatterIndex == nil ? "New" :"Edit")
        .navigationBarItems(trailing: Button("Save") {
            if title.isEmpty{
                showAlert = true
            }
            else{
                let matter = Matter(title: title, type: type, predictTime: predictTime, actualTime:actualTime,isDone: isDone, colorHex: colorHex, colorAlpha: Float(colorAlpha), selectDate: selectDate)
                if let editMatterIndex = editMatterIndex {
                    print(matter.colorAlpha)
                    scheduleData.schedule[editMatterIndex] = matter
                }else {
                    //print(matter.selectDate)
                    
                    scheduleData.schedule.insert(matter, at: 0)
                }
                self.presentationMode.wrappedValue.dismiss()
            }
            
        })
        .alert(isPresented:$showAlert){()-> Alert in
            return Alert(title: Text("標題不能為空"))
            
        }
    }
}

struct ScheduleEditor_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleEditor(scheduleData:ScheduleData())
    }
}


struct TypePicker: View {
    @Binding var type: Int
    var body: some View {
        Picker("類型",selection: $type){
            ForEach(0 ..< types.count) { (i) in
                Text(types[i])
                
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .scaleEffect(1.1)
        
    }
}

extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        print(a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}

extension UIColor {
    func toAlpha() -> Float {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let alpha = Float(a)
        return alpha
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

