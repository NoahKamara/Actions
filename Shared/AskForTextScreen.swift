import SwiftUI

struct AskForTextScreen: View {
	struct Data {
		var text: String
		var title: String
		var message: String?
		var timeout: Double?
		var timeoutReturnValue: String
		var showCancelButton = true
		var type: InputTypeAppEnum
	}

	@Environment(\.dismiss) private var dismiss
	@State private var text = ""
	@State private var isTimeoutCancelled = false
	@FocusState private var isFocused: Bool
	private let data: Data

	init(data: Data) {
		self.data = data
		self._text = .init(wrappedValue: data.text)
	}

	var body: some View {
		VStack {
			Button("Done") {
				XPasteboard.general.stringForCurrentHostOnly = text
				openShortcuts()
			}
				// TODO: The button disappears if the below is uncommented. (iOS 16.2)
				// TODO: Disable the button if not valid email, URL, etc, when using the types.
//				.disabled(text.isEmptyOrWhitespace)
			if data.showCancelButton {
				Button("Cancel", role: .cancel) {
					openShortcuts()
				}
			}
			// It's important that this is last as otherwise it shows only two "Done" buttons. (macOS 13.0)
			TextField("", text: $text)
				.lineLimit(4, reservesSpace: true) // Has no effect. (iOS 16.0)
				.focused($isFocused)
				#if canImport(UIKit)
				.textContentType(data.type.toContentType)
				.keyboardType(data.type.toKeyboardType ?? .default)
				.textInputAutocapitalization(data.type.shouldDisableAutocorrectionAndAutocapitalization ? .never : nil)
				.autocorrectionDisabled(data.type.shouldDisableAutocorrectionAndAutocapitalization)
				#endif
		}
			.onChange(of: text) { _ in
				isTimeoutCancelled = true
			}
			.task {
				#if canImport(AppKit)
				NSApp.activate(ignoringOtherApps: true)
				#endif

				// TODO: Does not work. (macoS 13.0)
				isFocused = true

				guard let timeout = data.timeout else {
					return
				}

				try? await Task.sleep(for: .seconds(timeout))

				guard !isTimeoutCancelled else {
					return
				}

				timeoutAction()
			}
	}

	@MainActor
	private func timeoutAction() {
		XPasteboard.general.stringForCurrentHostOnly = data.timeoutReturnValue
		openShortcuts()
	}

	@MainActor
	private func openShortcuts() {
		ShortcutsApp.open()
		dismiss() // TODO: Report to Apple: Dismiss should work inside an alert.
		AppState.shared.askForTextData = nil

		#if canImport(AppKit)
		DispatchQueue.main.async {
			SSApp.quit()
		}
		#endif
	}
}

//struct AskForTextScreen_Previews: PreviewProvider {
//	static var previews: some View {
//		AskForTextScreen()
//	}
//}
