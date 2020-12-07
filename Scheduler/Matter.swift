//
//  Matter.swift
//  Scheduler
//
//  Created by User14 on 2020/11/23.
//

import Foundation

struct Matter : Identifiable,Codable{
    var id = UUID()
    var title : String
    var type : Int
    var predictTime : Int
    var actualTime : Int?
    var isDone : Bool
    var colorHex : String
    var colorAlpha : Float
    var selectDate : Date
}

let types=["課業","休閒","運動","生活"]
