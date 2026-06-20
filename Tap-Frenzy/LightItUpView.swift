import SwiftUI

struct LightItUpView: View {
	var body: some View {
		VStack(spacing: 16) {
			Text("Light It Up")
				.font(.largeTitle.bold())
			Text("This mode is under construction.")
				.foregroundStyle(.secondary)
		}
		.navigationTitle("Light It Up")
		.padding()
	}
}

#Preview {
	LightItUpView()
}
