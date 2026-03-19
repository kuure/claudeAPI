import SwiftUI

struct ContentView: View {
    
    @State private var userMessage = ""
    @State private var response = ""
    @State private var isLoading = false

    
    var body: some View {
        
        
        VStack() {
            
            // title
            Text("Claude Chat")
                .font(.largeTitle.bold())
            
            // text box and button
            HStack {
                
                // the value here becomes "userMessage"
                TextField("Ask something...", text: $userMessage)
                    .textFieldStyle(.roundedBorder)

                // when clicked, call the sendMessage() function
                Button {
                    Task { await sendMessage() }
                } label: {
                    // image is based on a variable, isLoading
                    // if true, show the system image "ellipsis";
                    // otherwise show the up arrow
                    Image(
                        systemName: isLoading
                            ? "ellipsis"
                            : "arrow.up.circle.fill"
                    )
                    .font(.title2)
                }
                // if the text box is empty or 'isLoading' is true, disable
                // the button
                .disabled(userMessage.isEmpty || isLoading)
            }

            // where the AI response will be displayed
            ScrollView {
                // if the response is empty, use placeholder text; otherwise show the response
                Text(
                    response.isEmpty ? "Response will appear here..." : response)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    // if the response is empthy, use the 'secondary' color style
                    // if not empty, use the 'primary'
                    .foregroundStyle(response.isEmpty ? .secondary : .primary)
            }
            .frame(maxHeight: .infinity)
            .background(.yellow, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    
    // send message to the AI endpoint
    func sendMessage() async {
        
        let prompt = userMessage
        userMessage = ""
        response = ""
        // set the 'isLoading' to 'true' for now...
        isLoading = true


        // the query to send to the Claud AI
        // the "content" value is the prompt, aka the userMessage
        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]

        // this gets the data
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // IMPORTANT: your api key needs to go in the quotes here; DO NOT PUBLISH YOUR API KEY
        request.setValue("YOUR_API_KEY_GOES_HERE", forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        //
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let content = (json?["content"] as? [[String: Any]])?.first
            response = content?["text"] as? String ?? "No response"
        } catch {
            response = "Error: \(error.localizedDescription)"
        }
        
        // once everything done, turn off the isLoading flag
        isLoading = false
    }
}

#Preview {
    ContentView()
}
