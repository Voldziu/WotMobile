//
//  AddEventForm.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 10/12/2024.
//

import SwiftUI

struct AddEventForm: View {
    var clanId:Int
    var madeById: Int
    var rank:Int
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var datetimestart = Date()
    @State private var datetimeend = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var maxParticipants = 10
    

    var onAddEvent: (Event) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Event title", text: $title)
                DatePicker("Start Time ", selection: $datetimestart)
                    .onChange(of: datetimestart) {_, newValue in
                            // Jeśli data zakończenia jest wcześniejsza niż nowa data rozpoczęcia, aktualizujemy ją
                            if datetimeend < newValue {
                                datetimeend = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
                            }
                        }
                DatePicker("End Time", selection: $datetimeend)
                    .onChange(of: datetimeend) {_, newValue in
                            // Jeśli data zakończenia jest wcześniejsza niż nowa data rozpoczęcia, aktualizujemy ją
                            if datetimestart > newValue {
                                datetimestart = Calendar.current.date(byAdding: .hour, value: -1, to: newValue) ?? newValue
                            }
                        }
                Stepper("Max number of participants: \(maxParticipants)", value: $maxParticipants, in: 1...100)
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newEvent = Event(
                            title: title,
                            datetimestart: datetimestart,
                            datetimeend: datetimeend,
                            participants: [],
                            participantsID: [],
                            maxParticipants: maxParticipants,
                            clanId: clanId,
                            madeById: madeById,
                            rank:rank
                        )
                        onAddEvent(newEvent)
                        dismiss()
                    }
                }
            }
        }
    }
}



