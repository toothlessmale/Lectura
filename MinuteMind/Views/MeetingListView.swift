import SwiftUI

/// Displays meetings for a selected project.
struct MeetingListView: View {
    @StateObject private var viewModel: MeetingListViewModel
    @State private var newTitle = ""
    @State private var date = Date()
    @State private var showingNew = false

    init(project: Project) {
        _viewModel = StateObject(wrappedValue: MeetingListViewModel(project: project))
    }

    var body: some View {
        List {
            ForEach(viewModel.meetings) { meeting in
                NavigationLink(meeting.title ?? "Meeting") {
                    RecordingDetailView(meeting: meeting)
                }
            }
        }
        .navigationTitle(viewModel.project.name ?? "Meetings")
        .toolbar {
            Button(action: { showingNew = true }) { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showingNew) {
            VStack {
                TextField("Title", text: $newTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Button("Add") {
                    viewModel.addMeeting(title: newTitle, date: date)
                    newTitle = ""
                    showingNew = false
                }
                .disabled(newTitle.isEmpty)
                Spacer()
            }
            .padding()
            .presentationDetents([.fraction(0.45)])
        }
    }
}
