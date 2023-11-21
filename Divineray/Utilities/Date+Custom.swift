//
//  Date+Custom.swift
//  Wedswing
//
//  Created by Nitin Kumar on 27/06/18.
//  Copyright © 2018 Nitin Kumar. All rights reserved.
//

import UIKit

extension Date {
    
    static var tomorrow: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())
    }
    
    func dateToString(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    func timeFormatForChat() -> String {
        let date:String = ""
        if self.isToday {
            return "Today \(self.dateToString(format: "hh:mm a"))"
        } else if self.isYesterday {
            return "Yesterday \(self.dateToString(format: "hh:mm a"))"
        } else {
            return self.dateToString(format: "dd:mm:yy hh:mm a")
        }
    }
    
    
    
    
    var isToday:Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isYesterday:Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isTomorrow:Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    public func monthDays(year:Int, month:Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        print(numDays) // 31
        return numDays
    }
    
    func miliseconds() -> Double {
        return self.timeIntervalSince1970 * 1000
    }
    
    func dateToUTCString(format:String)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format  //Your New Date format as per requirement change it own
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let newDate = dateFormatter.string(from: self)
        print(newDate)
        return newDate
    }
    
    func dateToUTCString(format: String.format)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue  //Your New Date format as per requirement change it own
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let newDate = dateFormatter.string(from: self)
        print(newDate)
        return newDate
    }
    
    
    //date to string
//    func dateToString(format:String)->String {
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format  //Your New Date format as per requirement change it own
//        dateFormatter.locale = Locale(identifier: "en_US")
//        
//        let newDate = dateFormatter.string(from: self)
//        print(newDate)
//        return newDate
//    }
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "min ago" : "\(interval)" + " " + "mins ago"
        }
        
        return "just now"
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 {
            return years(from: date) == 1 ? "\(years(from: date))yr" : "\(years(from: date))yrs"
        }
        if months(from: date)  > 0 {
            return months(from: date) == 1 ? "\(months(from: date))month" : "\(months(from: date))months"
        }
        if weeks(from: date)   > 0 {
            return weeks(from: date) == 1 ? "\(weeks(from: date))week" : "\(weeks(from: date))weeks"
        }
        if days(from: date)    > 0 {
            return days(from: date) == 1 ? "\(days(from: date))day" : "\(days(from: date))days"
        }
        if hours(from: date)   > 0 {
            return hours(from: date) == 1 ? "\(hours(from: date))hr" : "\(hours(from: date))hrs"
        }
        if minutes(from: date) > 0 {
            return minutes(from: date) == 1 ? "\(minutes(from: date))min" : "\(minutes(from: date))mins"
        }
        if seconds(from: date) > 0 {
            return seconds(from: date) == 1 ? "\(seconds(from: date))sec" : "\(seconds(from: date))secs"
        }
        return "just now"
    }
    
    func timeAgo() -> String {
        return self.offset(from: Date())
    }
    
}

extension Date {
    
    var month: String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MMM"
           return dateFormatter.string(from: self)
       }
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        return dateFormatter.string(from: self)
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    
    func toStringStandard(format: String.format) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.local
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    func toString(format: String.format) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }
    
    var currentMonthDates: [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: self)!
        
        // Fetch Total days in a month
        let days = calendar.dateComponents([.day], from: self, to: interval.end).day!
        
        var dates: [Date] = []
        
        for i in 0..<days {
            let nextDay = calendar.date(byAdding: .day, value: i, to: self)
            dates.append(nextDay!)
        }
        
        return dates
    }
    
    var startTime: Date? {
        let date = self.toString(format: .ddM3y4)
        let start = "\(date) 00:00".changeToDate(withFormat: .ddM3y4HHmm)
        return start
    }
    
    var endTime: Date? {
        let date = self.toString(format: .ddM3y4)
        let end = "\(date) 23:59".changeToDate(withFormat: .ddM3y4HHmm)
        return end
    }
    
}
