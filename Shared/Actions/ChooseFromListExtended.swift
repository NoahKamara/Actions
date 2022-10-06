import AppIntents
import SwiftUI

struct ChooseFromListExtended: AppIntent, CustomIntentMigratedAppIntent {
	static let intentClassName = "ChooseFromListExtendedIntent"

	static let title: LocalizedStringResource = "Choose from List (Extended)"

	static let description = IntentDescription(
"""
Presents a searchable list where you can select one or multiple items.

It also supports setting a timeout and interactively adding custom items.

This is an extended version of the built-in "Choose from List" action.

Add the “Wait to Return” and “Get Clipboard” actions after this one.
""",
		categoryName: "Utility"
	)

	static let openAppWhenRun = true

	@Parameter(title: "List")
	var list: [String]

	@Parameter(title: "Prompt")
	var prompt: String?

	@Parameter(title: "Select Multiple", default: false)
	var selectMultiple: Bool

	@Parameter(title: "Select All Initially", default: false)
	var selectAllInitially: Bool

	@Parameter(title: "Allow Custom Items", default: false)
	var allowCustomItems: Bool

	@Parameter(title: "Use Timeout", default: false)
	var useTimeout: Bool

	@Parameter(title: "Timeout", default: 10, inclusiveRange: (1, 9999))
	var timeout: Double?

	@Parameter(title: "Return Value on Timeout", default: .nothing)
	var timeoutReturnValue: ChooseFromListTimeoutValueAppEnum

	static var parameterSummary: some ParameterSummary {
		When(\.$selectMultiple, .equalTo, true) {
			When(\.$useTimeout, .equalTo, true) {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$selectMultiple
					\.$selectAllInitially
					\.$useTimeout
					\.$timeout
					\.$timeoutReturnValue
					\.$allowCustomItems
				}
			} otherwise: {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$selectMultiple
					\.$selectAllInitially
					\.$useTimeout
					\.$allowCustomItems
				}
			}
		} otherwise: {
			When(\.$useTimeout, .equalTo, true) {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$selectMultiple
					\.$useTimeout
					\.$timeout
					\.$timeoutReturnValue
					\.$allowCustomItems
				}
			} otherwise: {
				Summary("Choose from \(\.$list)") {
					\.$prompt
					\.$selectMultiple
					\.$useTimeout
					\.$allowCustomItems
				}
			}
		}
	}

	@MainActor
	func perform() async throws -> some IntentResult {
		#if canImport(UIKit)
		UIView.setAnimationsEnabled(false)
		#endif

		AppState.shared.chooseFromListData = .init(
			list: list,
			title: prompt?.nilIfEmptyOrWhitespace,
			selectMultiple: selectMultiple,
			selectAllInitially: selectAllInitially,
			allowCustomItems: allowCustomItems,
			timeout: useTimeout ? timeout : nil,
			timeoutReturnValue: timeoutReturnValue
		)

		return .result()
	}
}

enum ChooseFromListTimeoutValueAppEnum: String, AppEnum {
	case nothing
	case firstItem
	case lastItem
	case randomItem

	static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Choose from List Timeout Value")

	static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.nothing: "Nothing",
		.firstItem: "First Item",
		.lastItem: "Last Item",
		.randomItem: "Random Item"
	]
}
