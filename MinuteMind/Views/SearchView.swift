import SwiftUI

/// Global transcript search view.
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        List {
            ForEach(viewModel.results) { rec in
                VStack(alignment: .leading) {
                    Text(rec.meeting?.title ?? "Meeting")
                        .font(.headline)
                    if let snippet = rec.transcript {
                        Text(snippet)
                            .lineLimit(2)
                    }
                }
            }
        }
        .searchable(text: $viewModel.query)
        .navigationTitle("Search")
    }
}
