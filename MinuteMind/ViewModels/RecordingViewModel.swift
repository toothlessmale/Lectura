import Foundation
import CoreData

/// Handles recording audio and requesting transcripts/summaries.
@MainActor
final class RecordingViewModel: ObservableObject {
    @Published var currentTranscript: String = ""
    @Published var currentSummary: String = ""
    @Published var recordings: [Recording] = []
    @Published var isRecording = false

    private let context: NSManagedObjectContext
    private let meeting: Meeting
    private let audioService = AudioRecorderService()
    private let openAI = OpenAIService.shared
    private let persistence = PersistenceController.shared
    private var recordingURL: URL?

    init(meeting: Meeting, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.meeting = meeting
        self.context = context
        fetchRecordings()
    }

    func fetchRecordings() {
        let request = Recording.fetchRequest()
        request.predicate = NSPredicate(format: "meeting == %@", meeting)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recording.timestamp, ascending: false)]
        recordings = (try? context.fetch(request)) ?? []
    }

    /// Begin capturing audio.
    func start() {
        do {
            recordingURL = try audioService.startRecording()
            isRecording = true
        } catch {
            print("Unable to start recording: \(error)")
        }
    }

    /// Stop recording and trigger transcription & summary.
    func stop() {
        guard let result = audioService.stopRecording() else { return }
        isRecording = false
        let recording = Recording(context: context)
        recording.id = UUID()
        recording.timestamp = Date()
        recording.duration = result.duration
        recording.audioFileURL = result.url.path
        recording.meeting = meeting
        persistence.save(context: context)
        fetchRecordings()

        Task {
            do {
                let transcript = try await openAI.transcribeAudio(fileURL: result.url)
                recording.transcript = transcript
                let summary = try await openAI.summariseTranscript(transcript)
                recording.summary = summary
                persistence.save(context: context)
                await MainActor.run {
                    currentTranscript = transcript
                    currentSummary = summary
                    fetchRecordings()
                }
            } catch {
                print("Network error: \(error)")
                // Leave transcript/summary nil for retry later.
            }
        }
    }
}
