import SwiftUI

struct HomeView: View {
	private typealias TapFrenzyView = ContentView

	var body: some View {
		NavigationStack {
			VStack(spacing: 24) {
				Text("Choose a Game Mode")
					.font(.largeTitle.bold())

				NavigationLink("Tap Frenzy") {
					TapFrenzyView()
				}
				.buttonStyle(.borderedProminent)

				NavigationLink("Light It Up") {
					LightItUpView()
				}
				.buttonStyle(.borderedProminent)
                
                NavigationLink("Quiz Rush") {
                    QuizRushView()
                }
                .buttonStyle(.borderedProminent)
			}
			.padding()
		}
	}
}

#Preview {
	HomeView()
}
