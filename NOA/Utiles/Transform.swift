//
//  Transform.swift
//  NOA
//
//  Created by wi_seong on 2022/06/02.
//

import Foundation

class Transform {
    static let shared = Transform()
    
    internal func getDate(_ time: String) -> [String] {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let date: Date = dateFormatter.date(from: time)!
        let changedDate = DateFormatter()
        
        changedDate.locale = Locale(identifier: "ko_KR")
        changedDate.timeZone = TimeZone(abbreviation: "KST")
        changedDate.dateFormat = "yyyy"
        let yearOutput = changedDate.string(from: date)
        
        changedDate.locale = Locale(identifier: "ko_KR")
        changedDate.timeZone = TimeZone(abbreviation: "KST")
        changedDate.dateFormat = "M월 d일 "
        let dateOutput = changedDate.string(from: date)
        
        changedDate.locale = Locale(identifier: "ko_KR")
        changedDate.dateFormat = "a h:mm"
        let time = changedDate.string(from: date)
        
        let kr = [yearOutput, dateOutput, time]
        
        return kr
    }
    
    internal func messageDate(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let messageKST = String2DateType(time)
        
        let messageDateString = formatter.string(from: messageKST!)
        let messageDate = getDate(messageDateString)
        
        let currentDateString = formatter.string(from: Date())
        let currentDate = getDate(currentDateString)
        
        if messageDate[0] != currentDate[0] {
            let year = Int(currentDate[0])! - Int(messageDate[0])!
            if year == 1 { return "작년"}
            else { return "\(year)년 전" }
        } else if messageDate[1] != currentDate[1] {
            return messageDate[1]
        } else {
            return messageDate[2]
        }
    }
    
    internal func messageDay(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let messageKST = String2DateType(time)
        
        let messageDateString = formatter.string(from: messageKST!)
        let messageDate = getDate(messageDateString)
        
        return "\(messageDate[0])년 \(messageDate[1])"
    }
    
    internal func messageTimestamp(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let messageKST = String2DateType(time)
        
        let messageDateString = formatter.string(from: messageKST!)
        let messageDate = getDate(messageDateString)
        
        return messageDate[2]
    }
    
    internal func sendTimestamp(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let messageKST = String2DateType(time)
        
        let messageDateString = formatter.string(from: messageKST!)
        let messageDate = getDate(messageDateString)
        
        return messageDate[2]
    }
    
    func compareDate(_ date1: String, _ date2: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let date1KST = String2DateType(date1)
        let date2KST = String2DateType(date2)
        
        let date1String = formatter.string(from: date1KST!)
        let date2String = formatter.string(from: date2KST!)
        
        let d1 = getDate(date1String)
        let d2 = getDate(date2String)
        
        if d1[0] != d2[0] || d1[1] != d2[1]{
            
            return true
        } else {
            return false
        }
    }
    
    internal func dateToKTime(time: Date, format: String) -> String {
        print(time)
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_KR")
        date.timeZone = TimeZone(abbreviation: "KST")
        
        date.dateFormat = format
        let kr = date.string(from: time)
        
        return kr
    }
    
    func String2DateType(_ string : String) -> Date?{
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.date(from: string)
    }
}
