//
//  AchievementsView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez.
//  Version: 1.0 - Vista de logros desbloqueados
//  Last modified: 08/10/2025
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var streakVM: StreakViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if streakVM.achievements.isEmpty {
                    emptyAchievementsView
                } else {
                    achievementsListView
                }
            }
            .navigationTitle("Logros Desbloqueados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyAchievementsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Aún no hay logros")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Completa tareas consecutivas para desbloquear logros")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var achievementsListView: some View {
        List {
            Section(header: Text("Logros Desbloqueados (\(streakVM.achievements.count))")) {
                ForEach(streakVM.achievements.sorted(by: { $0.unlockedAt > $1.unlockedAt })) { achievement in
                    HStack(spacing: 15) {
                        Text(achievement.icon)
                            .font(.title2)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            Text("Desbloqueado: \(formattedDate(achievement.unlockedAt))")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Estadísticas")) {
                HStack {
                    Text("Racha Actual")
                    Spacer()
                    Text("\(streakVM.currentStreak) días")
                        .fontWeight(.semibold)
                        .foregroundColor(streakVM.currentStreak > 0 ? .orange : .gray)
                }
                
                HStack {
                    Text("Racha Más Larga")
                    Spacer()
                    Text("\(streakVM.longestStreak) días")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Progreso Semanal")
                    Spacer()
                    Text("\(Int(streakVM.weeklyCompletion * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environmentObject(StreakViewModel.preview)
    }
}
