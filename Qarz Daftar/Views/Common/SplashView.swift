import SwiftUI

struct SplashView: View {
    let language: AppLanguage

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentColor)
                Text(L10n.text(.appName, language))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                Text(L10n.text(.splashSubtitle, language))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
