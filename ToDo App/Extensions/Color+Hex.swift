//
//  Color+hex.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 28.06.2024.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgba: UInt64 = 0
        scanner.scanHexInt64(&rgba)
        
        let rParam, gParam, bParam, aParam: Double
        if hex.count == 9 {
            rParam = Double((rgba >> 24) & 0xFF) / 255.0
            gParam = Double((rgba >> 16) & 0xFF) / 255.0
            bParam = Double((rgba >> 8) & 0xFF) / 255.0
            aParam = Double(rgba & 0xFF) / 255.0
        } else {
            rParam = Double((rgba >> 16) & 0xFF) / 255.0
            gParam = Double((rgba >> 8) & 0xFF) / 255.0
            bParam = Double(rgba & 0xFF) / 255.0
            aParam = 1.0
        }
        
        self.init(red: rParam, green: gParam, blue: bParam, opacity: aParam)
    }
    
    var hexString: String {
        let components = self.cgColor?.components
        let rParam = components?[0] ?? 0
        let gParam = components?[1] ?? 0
        let bParam = components?[2] ?? 0
        let aParam = components?[3] ?? 1
        return String(format: "#%02X%02X%02X%02X", Int(rParam * 255), Int(gParam * 255), Int(bParam * 255), Int(aParam * 255))
    }
}
