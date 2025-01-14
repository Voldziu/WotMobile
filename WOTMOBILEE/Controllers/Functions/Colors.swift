//
//  Colors.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation
import UIKit

enum WN8Color {
    case red
    case orange
    case yellow
    case green
    case turquoise
    case purple

    // Computed property to get the associated UIColor
    var color: UIColor {
        switch self {
        case .red: return UIColor.red
        case .orange: return UIColor.orange
        case .yellow: return UIColor.yellow
        case .green: return UIColor.green
        case .turquoise: return UIColor.systemTeal // Closest match for turquoise
        case .purple: return UIColor.purple
        }
    }
}

func getColorFromWn8(wn8Value: Int) -> UIColor {
    switch wn8Value {
    case ..<580:
        return WN8Color.red.color
    case 580..<1094:
        return WN8Color.orange.color
    case 1094..<1716:
        return WN8Color.yellow.color
    case 1716..<2657:
        return WN8Color.green.color
    case 2657..<3672:
        return WN8Color.turquoise.color
    default:
        return WN8Color.purple.color
    }
}

func getColorFromWinrate(wrValue:Double) -> UIColor {
    switch wrValue {
    case ..<46.10:
        return WN8Color.red.color
    case 46.10..<49.17:
        return WN8Color.orange.color
    case 49.17..<52.7:
        return WN8Color.yellow.color
    case 52.7..<58.04:
        return WN8Color.green.color
    case 58.04..<63.62:
        return WN8Color.turquoise.color
    default:
        return WN8Color.purple.color
    }
}
