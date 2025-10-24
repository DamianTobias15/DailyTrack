//
//  HabitStatsView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/9/25.
//  Version 1.0 - Fase 8: Vista de estadísticas de hábitos
//

import SwiftUI

struct HabitStatsView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var selectedTimeFrame: TimeFrame = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con resumen general
                    headerSection
                    
                    // Métricas principales
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        completionRateCard
                        streakCard
                        consistencyCard
                        habitsCountCard
                    }
                    
                    // Hábitos por frecuencia
                    habitsByFrequencySection
                    
                    // Hábitos que necesitan atención
                    attentionNeededSection
                    
                    // Top hábitos por racha
                    topHabitsSection
                    
                    // Gráfico de consistencia semanal
                    weeklyConsistencyChart
                }
                .padding()
            }
            .navigationTitle("Estadísticas de Hábitos")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Secciones de la Vista
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tu Progreso de Hábitos")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Consistencia: \(taskViewModel.generateHabitReport().formattedConsistency)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: taskViewModel.habitCompletionRate, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var completionRateCard: some View {
        StatCard(
            title: "Completados Hoy",
            value: "\(taskViewModel.generateHabitReport().completedToday)/\(taskViewModel.generateHabitReport().totalHabits)",
            subtitle: taskViewModel.generateHabitReport().formattedCompletionRate,
            icon: "checkmark.circle.fill",
            color: .green
        )
    }
    
    private var streakCard: some View {
        StatCard(
            title: "Racha Más Larga",
            value: "\(taskViewModel.generateHabitReport().longestStreak)",
            subtitle: "días consecutivos",
            icon: "flame.fill",
            color: .orange
        )
    }
    
    private var consistencyCard: some View {
        StatCard(
            title: "Consistencia",
            value: taskViewModel.generateHabitReport().formattedConsistency,
            subtitle: "promedio general",
            icon: "chart.line.uptrend.xyaxis",
            color: .blue
        )
    }
    
    private var habitsCountCard: some View {
        StatCard(
            title: "Total Hábitos",
            value: "\(taskViewModel.generateHabitReport().totalHabits)",
            subtitle: "activos",
            icon: "repeat",
            color: .purple
        )
    }
    
    private var habitsByFrequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hábitos por Frecuencia")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                    FrequencyStatCard(frequency: frequency, count: taskViewModel.habitsByFrequency(frequency).count)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var attentionNeededSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Necesitan Atención")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if taskViewModel.habitsNeedingAttention().count > 0 {
                    Text("\(taskViewModel.habitsNeedingAttention().count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            
            if taskViewModel.habitsNeedingAttention().isEmpty {
                Text("¡Todos tus hábitos van bien! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(taskViewModel.habitsNeedingAttention().prefix(3)) { habit in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(habit.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Consistencia: \(String(format: "%.1f", habit.consistencyPercentage() * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(habit.habitStreak) días")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var topHabitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Récords de Rachas")
                .font(.headline)
                .fontWeight(.semibold)
            
            if taskViewModel.topHabitsByStreak(limit: 3).isEmpty {
                Text("Aún no tienes hábitos con rachas largas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(taskViewModel.topHabitsByStreak(limit: 3)) { habit in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(habit.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(habit.frequencyDescription)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(habit.habitStreak)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var weeklyConsistencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Consistencia Semanal")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Gráfico simple de barras para la consistencia semanal
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { day in
                    VStack {
                        Rectangle()
                            .fill(day % 2 == 0 ? Color.blue : Color.blue.opacity(0.6))
                            .frame(width: 20, height: CGFloat.random(in: 30...100))
                            .cornerRadius(4)
                        
                        Text(dayName(for: day))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    private func dayName(for index: Int) -> String {
        let days = ["L", "M", "X", "J", "V", "S", "D"]
        return days[index]
    }
}

// MARK: - Componentes de Tarjetas

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct FrequencyStatCard: View {
    let frequency: HabitFrequency
    let count: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(frequency.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch frequency {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar"
        case .monthly: return "moon.stars.fill"
        }
    }
    
    private var color: Color {
        switch frequency {
        case .daily: return .orange
        case .weekly: return .blue
        case .monthly: return .purple
        }
    }
}

// MARK: - Enums de Apoyo

enum TimeFrame {
    case week, month, year
}

// MARK: - Preview

#Preview {
    HabitStatsView()
        .environmentObject(TaskViewModel.preview)
}
