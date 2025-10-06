//
//  collaborator.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/6/25.
//

import Foundation

struct Collaborator: Identifiable, Codable {
    var id = UUID()
    var name: String
    var phone: String
    var email: String?
}
