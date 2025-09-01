import SwiftUI

/// Top-level view listing all projects.
struct ProjectListView: View {
    @StateObject private var viewModel = ProjectListViewModel()
    @State private var newName: String = ""
    @State private var showingNew = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.projects) { project in
                    NavigationLink(project.name ?? "Untitled") {
                        MeetingListView(project: project)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SearchView()) { Image(systemName: "magnifyingglass") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavigationLink(destination: SettingsView()) { Image(systemName: "gearshape") }
                        Button(action: { showingNew = true }) { Image(systemName: "plus") }
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                VStack {
                    TextField("Project name", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button("Add") {
                        viewModel.addProject(name: newName)
                        newName = ""
                        showingNew = false
                    }
                    .disabled(newName.isEmpty)
                    Spacer()
                }
                .presentationDetents([.fraction(0.25)])
            }
        }
    }
}

#Preview {
    ProjectListView()
}
