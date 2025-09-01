import Foundation

/// Handles communication with OpenAI APIs for transcription and summarisation.
final class OpenAIService {
    static let shared = OpenAIService()
    private init() {}

    private var apiKey: String {
        // Prefer user provided key from Keychain, fall back to bundled key.
        if let key = KeychainManager.shared.fetchAPIKey() { return key }
        return Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    }

    /// Uploads audio to Whisper for transcription.
    func transcribeAudio(fileURL: URL) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // model field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\nwhisper-1\r\n".data(using: .utf8)!)
        // file field
        let audioData = try Data(contentsOf: fileURL)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)
        struct Response: Decodable { let text: String }
        return try JSONDecoder().decode(Response.self, from: data).text
    }

    /// Summarises a transcript into key points, decisions and action items using GPT.
    func summariseTranscript(_ transcript: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let prompt = """
        Summarise the following meeting transcript into:
        - Key points
        - Decisions
        - Action Items (with owners and due dates if mentioned)
        - Open Questions
        Transcript: \n\(transcript)
        """
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        struct Choice: Decodable { let message: Message }
        struct Message: Decodable { let content: String }
        struct SummaryResponse: Decodable { let choices: [Choice] }
        let decoded = try JSONDecoder().decode(SummaryResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }
}
