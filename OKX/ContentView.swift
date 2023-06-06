import LocalAuthentication
import SwiftUI

struct ContentView: View {
    @State private var isUnlocked = false
    @State private var hasBiometry = true
    @State private var authStatus: AuthenticationStatus = .none

    var body: some View {
        NavigationView {
            VStack {
                if !hasBiometry {
                    PasscodeField(maxDigits: 4) { digits, _ in
                        if checkPasscodeValidity(passcodeString: digits.concat) {
                            isUnlocked = true
                        }
                    } label: {
                        passTitleView()
                    }
                } else {
                    Text(authStatus.message)
                        .padding(.top, 100)
                    Spacer()
                }
                NavigationLink("", destination: DetailView(), isActive: $isUnlocked)
            }
            .navigationTitle("Registration")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkBiometricAuthentication()
            }
            .padding()
        }
    }

    private func passTitleView() -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Security Number")
                .font(.title)
                .foregroundColor(Color(.label))

            Text("4 digits")
                .font(.footnote)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}



extension ContentView {
    func checkBiometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        let reason = "Log in with your biometric authentication."
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Biometric authentication is available
            authStatus = .inProgress
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    } else {
                        authStatus = .error
                    }
                }
            }
        } else {
            hasBiometry = false
        }
    }

    func checkPasscodeValidity(passcodeString: String?) -> Bool {
        guard let passcodeString = passcodeString else {
            return false
        }
        return validatePasscode(passcodeString)
    }

    private func validatePasscode(_ passcode: String) -> Bool {
        // Always return true, Since this project only demo UI, not a full register flow.
        // passcode == KeyManager.sharedManager.retrievePasskey()
        true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
