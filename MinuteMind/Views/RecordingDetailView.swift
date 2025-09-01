import SwiftUI
import UIKit

/// Detail view for a meeting showing recordings, transcripts and summaries.
struct RecordingDetailView: View {
    @StateObject private var viewModel: RecordingViewModel
    @State private var showShare: Recording?

    init(meeting: Meeting) {
        _viewModel = StateObject(wrappedValue: RecordingViewModel(meeting: meeting))
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.recordings) { rec in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rec.timestamp ?? Date(), style: .time)
                            .font(.headline)
                        if let transcript = rec.transcript {
                            Text(transcript).lineLimit(2)
                        } else {
                            Text("Pending transcription...").italic()
                        }
                        if let summary = rec.summary {
                            Text(summary).font(.caption)
                        }
                    }
                    .onTapGesture { showShare = rec }
                }
            }
            HStack {
                Button(action: viewModel.isRecording ? viewModel.stop : viewModel.start) {
                    Image(systemName: viewModel.isRecording ? "stop.circle" : "record.circle")
                        .font(.system(size: 60))
                        .foregroundColor(viewModel.isRecording ? .red : .green)
                }
            }
            .padding()
        }
        .navigationTitle("Recordings")
        .sheet(item: $showShare) { rec in
            let text = "Transcript:\n\(rec.transcript ?? "")\n\nSummary:\n\(rec.summary ?? "")"
            ActivityView(activityItems: [text])
        }
    }
}

/// UIKit wrapper to present share sheet.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
