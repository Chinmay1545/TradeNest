import SwiftUI

extension View {
    /// Shows a ViewModel's `errorMessage` as an alert, and clears it when the user taps OK.
    /// Usage: `.errorAlert($vm.errorMessage)`
    func errorAlert(_ message: Binding<String?>) -> some View {
        alert("Something went wrong", isPresented: Binding(
            get: { message.wrappedValue != nil },
            set: { if !$0 { message.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
