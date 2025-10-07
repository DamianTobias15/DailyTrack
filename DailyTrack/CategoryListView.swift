//
//  CategoryListView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/7/25.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskVM.categories) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .frame(width: 30)
                        
                        Text(category.name)
                        
                        Spacer()
                        
                        Text("\(taskVM.tasksForCategory(category.id).count)")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Categorías")
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
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView()
            .environmentObject(TaskViewModel.preview)
    }
}
