import Foundation
import AVFoundation

/// Manages audio recording sessions using AVAudioRecorder.
final class AudioRecorderService: NSObject, ObservableObject {
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    @Published var isRecording = false

    /// Start a new recording and return the file URL.
    func startRecording() throws -> URL {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.record()
        recordingURL = url
        isRecording = true
        return url
    }

    /// Stop recording and return the audio file URL along with duration.
    func stopRecording() -> (url: URL, duration: TimeInterval)? {
        guard let recorder, let url = recordingURL else { return nil }
        recorder.stop()
        isRecording = false
        return (url, recorder.currentTime)
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {}
