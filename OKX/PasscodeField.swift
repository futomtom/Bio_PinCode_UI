import SwiftUI

public struct PasscodeField<Label>: View where Label: View {
    private let maxDigits: Int
    private let action: (DigitGroup, (Bool) -> Void) -> Void
    private let label: () -> Label

    public init(
        maxDigits: Int = 4,
        action: @escaping (DigitGroup, (Bool) -> Void) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.maxDigits = maxDigits
        self.action = action
        self.label = label
        pin = .blank(upTo: maxDigits)
    }

    @State private var pin: DigitGroup
    @State private var hidesPin: Bool = true
    @State private var disableHighlight: Bool = true

    public var body: some View {
        VStack(spacing: 20) {
            label()
            ZStack {
                pinDots
                backgroundField
            }
            .fixedSize(horizontal: true, vertical: true)
            showPinStack
        }
    }

    private var pinDots: some View {
        PinSquareGroup(digitGroup: $pin, isHidden: $hidesPin, disableHighlight: $disableHighlight, style: .pin)
    }

    private var backgroundField: some View {
        let boundPin = Binding<String>(
            get: { pin.concat },
            set: { newValue in
                pin = .init(digits: newValue.map { $0 }, upTo: maxDigits)
                if newValue.count == maxDigits {
                    submitPin()
                }
            }
        )

        return TextField("", text: boundPin, onCommit: submitPin)
            .accentColor(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
            .textFieldStyle(.plain)
            .disableAutocorrection(true)
            .onTapGesture {
                disableHighlight = false
            }
    }

    private var showPinStack: some View {
        HStack {
            Spacer()
            if !pin.isEmpty {
                showPinButton
            }
        }
        .frame(height: 20)
        .padding(.trailing)
    }

    private var showPinButton: some View {
        Button {
            hidesPin.toggle()
        } label: {
            hidesPin ? Image(systemName: "eye.slash.fill") : Image(systemName: "eye.fill")
        }
    }

    private func submitPin() {
        guard !pin.isEmpty else {
            hidesPin = true
            return
        }

        action(pin) { isSuccess in
            if isSuccess {
            } else {
                pin = .blank(upTo: maxDigits)
            }
        }
    }
}

public extension PasscodeField where Label == Text {
    init(
        _ title: some StringProtocol,
        maxDigits: Int = 4,
        action: @escaping (DigitGroup, (Bool) -> Void) -> Void
    ) {
        self.init(maxDigits: maxDigits, action: action) {
            Text(title)
                .font(.title)
        }
    }
}

public struct SquareStyle: Equatable, Hashable {
    public var width: CGFloat = 48
    public var cornerRadius: CGFloat = 6
    public var borderWidth: CGFloat = 2
    public var borderColor: Color = .init(.systemGray2)
    public var backgroundColor: Color = .init(.systemGray2)
    public var highlightedColor: Color = .accentColor
}

public extension SquareStyle {
    static let pin: SquareStyle = .init()
}

public struct PinSquare: View {
    private let digit: Character?
    private let isHidden: Bool
    private let isHighlighted: Bool
    private let style: SquareStyle

    public init(
        digit: Character?,
        isHidden: Bool,
        isHighlighted: Bool,
        style: SquareStyle
    ) {
        self.digit = digit
        self.isHidden = isHidden
        self.isHighlighted = isHighlighted
        self.style = style
    }

    public var body: some View {
        Text(isHidden ? "" : (digit.flatMap(String.init) ?? ""))
            .font(.title)
            .frame(width: style.width, height: style.width, alignment: .center)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(isHighlighted ? style.highlightedColor : style.borderColor, lineWidth: style.borderWidth)
                    .background((digit == nil || !isHidden) ? Color(.clear) : style.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            )
    }
}

public extension PinSquare {
    func highlighted(_ highlighted: Bool) -> Self {
        PinSquare(digit: digit, isHidden: isHidden, isHighlighted: highlighted, style: style)
    }

    func squareStyle(_ style: SquareStyle) -> Self {
        PinSquare(digit: digit, isHidden: isHidden, isHighlighted: isHighlighted, style: style)
    }
}

public struct SquareGroupStyle: Equatable, Hashable {
    public var squareStyle: SquareStyle = .pin
    public var spacing: CGFloat = 24
}

public extension SquareGroupStyle {
    static let pin: SquareGroupStyle = .init()
}

public struct DigitGroup: Equatable, Hashable {
    public struct IndexedDigit: Equatable, Hashable {
        public let index: Int
        public let digit: Character?
    }

    public private(set) var indexed: [IndexedDigit]

    public var currentIndex: Int? {
        let firstBlank = indexed.first { $0.digit == nil }?.index
        if firstBlank == nil {
            if concat.isEmpty {
                return 0
            } else {
                return concat.count - 1
            }
        } else {
            return firstBlank
        }
    }

    public var concat: String {
        indexed.compactMap { $0.digit.map(String.init) }.reduce("", +)
    }

    public var isEmpty: Bool {
        concat.isEmpty
    }

    public init(digits: [Character?], upTo maxLength: Int) {
        let processed: [Character?]
        if digits.count <= maxLength {
            processed = digits + .init(repeating: nil, count: maxLength - digits.count)
        } else {
            processed = Array(digits.prefix(maxLength))
        }
        indexed = processed.enumerated().map(IndexedDigit.init)
    }

    public static func blank(upTo maxLength: Int) -> DigitGroup {
        .init(digits: .init(repeating: nil, count: maxLength), upTo: maxLength)
    }
}

extension DigitGroup.IndexedDigit: Identifiable {
    public var id: Int {
        index
    }
}

public struct PinSquareGroup: View {
    @Binding public var digitGroup: DigitGroup
    @Binding public var isHidden: Bool
    @Binding public var disableHighlight: Bool
    public let style: SquareGroupStyle

    public var body: some View {
        HStack(alignment: .center, spacing: style.spacing) {
            ForEach(digitGroup.indexed) { indexedDigit in
                PinSquare(
                    digit: indexedDigit.digit,
                    isHidden: isHidden,
                    isHighlighted: disableHighlight ? false : digitGroup.currentIndex == indexedDigit.index,
                    style: style.squareStyle
                )
            }
        }
    }
}

extension String {
    var digits: [Int] {
        var result = [Int]()

        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }

        return result
    }
}

struct PasscodeField_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeField("Please Enter Passcode") { digits, action in
            if digits.concat == "1234" {
                action(true)
            } else {
                action(false)
            }
        }
    }
}
