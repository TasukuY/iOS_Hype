//
//  DateExtension.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import Foundation

extension Date {
    
    //MARK: - Helper Methods
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
    
}//End of extension
