//
//  formatDateWithIntervalBehind.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 25/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import Foundation

extension Date {
    func formatDateWithIntervalBehind(_ qtyDays: Int) -> String {
        
        let date = Date().addingTimeInterval(60*60*24*Double(qtyDays))
        let temp = DateFormatter()
        temp.locale = Locale(identifier: "pt_BR")
        temp.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        temp.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        return temp.string(from: date)
    }
}
