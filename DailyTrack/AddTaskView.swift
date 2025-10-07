//
//  AddTaskView.swift
//  DailyTrack
//
//  Created by Erick Damian Tobias Valdez on 10/7/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskVM: TaskViewModel

    @State private var title = ""
    @State private var reminderDate = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles de la tarea")) {
                    TextField("Título", text: $title)
                    DatePicker("Recordatorio", selection: $reminderDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Nueva Tarea")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        let newTask = Task(title: title, reminderDate: reminderDate)
                        taskVM.addTask(newTask)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
