import SwiftUI

struct DetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let text = """
    Account Created!
 App should send request to server to **deployed** a smart contract wallet to the Ethereum network
"""

    var body: some View {
        VStack {
            Text(.init(text))
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .navigationTitle("Detail")
        .navigationBarBackButtonHidden()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}


