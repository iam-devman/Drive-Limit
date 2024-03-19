//
//  File.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/2/23.
//

import Foundation


func getCurrentDateAsString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDate = Date()
    let dateString = dateFormatter.string(from: currentDate)
    return dateString
}

func convertStringToDate(string: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let date = dateFormatter.date(from: string)
    return date
}
