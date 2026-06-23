import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BaseViewModelMacro: MemberMacro, ExtensionMacro, MemberAttributeMacro {

    // MARK: - MemberAttributeMacro
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else { return [] }

        let mode = getMode(from: node)

        var attributes: [AttributeSyntax] = []

        // Handle property wrappers conflict with @Observable
        if mode == "observable",
           let varDecl = member.as(VariableDeclSyntax.self),
           !varDecl.attributes.isEmpty {
            let hasPropertyWrapper = varDecl.attributes.contains { attr in
                guard let attr = attr.as(AttributeSyntax.self) else { return false }
                let name = attr.attributeName.trimmedDescription
                return name.contains("Injected") || name.contains("Preference") || name.contains("Environment")
            }
            if hasPropertyWrapper {
                attributes.append("@ObservationIgnored")
            }
        }

        // Only add @Published to 'state' if in .observed mode
        if mode == "observed",
           let varDecl = member.as(VariableDeclSyntax.self),
           let firstBinding = varDecl.bindings.first,
           let identifier = firstBinding.pattern.as(IdentifierPatternSyntax.self),
           identifier.identifier.text == "state" {
            attributes.append("@SwiftUI.Published")
        }

        return attributes
    }

    // MARK: - MemberMacro
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroDiagnostic.onlyApplicableToClass
        }

        let mode = getMode(from: node)
        let memberList = classDecl.memberBlock.members

        // Check for State and Action
        let hasState = memberList.contains { member in
            if let structDecl = member.decl.as(StructDeclSyntax.self), structDecl.name.text == "State" { return true }
            if let enumDecl = member.decl.as(EnumDeclSyntax.self), enumDecl.name.text == "State" { return true }
            if let typeAlias = member.decl.as(TypeAliasDeclSyntax.self), typeAlias.name.text == "State" { return true }
            return false
        }

        let hasAction = memberList.contains { member in
            if let enumDecl = member.decl.as(EnumDeclSyntax.self), enumDecl.name.text == "Action" { return true }
            if let structDecl = member.decl.as(StructDeclSyntax.self), structDecl.name.text == "Action" { return true }
            if let typeAlias = member.decl.as(TypeAliasDeclSyntax.self), typeAlias.name.text == "Action" { return true }
            return false
        }

        let hasTrigger = memberList.contains { member in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { return false }
            return funcDecl.name.text == "trigger"
        }



        let isFinal = classDecl.modifiers.contains { modifier in
            guard let name = modifier.as(DeclModifierSyntax.self)?.name.text else { return false }
            return name == "final"
        }

        let modifiers = classDecl.modifiers.map { $0.as(DeclModifierSyntax.self)?.name.text ?? "" }
        let isPublic = modifiers.contains("public")
        let isOpen = modifiers.contains("open")
        let isFilePrivate = modifiers.contains("fileprivate")
        let isPrivate = modifiers.contains("private")

        let baseAccess: String
        if isOpen || isPublic {
            baseAccess = "public"
        } else if isFilePrivate {
            baseAccess = "fileprivate"
        } else if isPrivate {
            baseAccess = "private"
        } else {
            baseAccess = ""
        }

        let bindingsAccess: String
        if isOpen && !isFinal {
            bindingsAccess = "open"
        } else {
            bindingsAccess = baseAccess
        }

        let inheritance = classDecl.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []
        let inheritsFromBase = inheritance.contains { $0.contains("BaseViewModel") }

        // Only call super.init() for non-BaseViewModel superclasses (e.g. NSObject).
        // inheritsFromBase is handled separately in the init block.
        let hasSuperClass = !inheritance.isEmpty && !inheritsFromBase

        let space = { (s: String) in s.isEmpty ? "" : s + " " }

        var results: [DeclSyntax] = []

        if !hasState {
            results.append("\(raw: space(baseAccess))struct State { \(raw: space(baseAccess))init() {} }")
        }

        if !hasAction {
            results.append("\(raw: space(baseAccess))enum Action {}")
        }

        if !hasTrigger {
            results.append("\(raw: space(baseAccess))@discardableResult func trigger(_ action: Action) -> ViewModelEffect { .none }")
        }

        if !inheritsFromBase {
            if mode == "observed" {
                results.append("@SwiftUI.Published \(raw: space(baseAccess))var state: State")
            } else {
                results.append("\(raw: space(baseAccess))var state: State")
            }
            results.append("\(raw: space(bindingsAccess))var bindings: [Combine.AnyCancellable] { [] }")

            if mode == "observable" {
                results.append("@ObservationIgnored \(raw: space(baseAccess))var cancelables: Set<Combine.AnyCancellable> = []")
            } else {
                results.append("\(raw: space(baseAccess))var cancelables: Set<Combine.AnyCancellable> = []")
            }

            if mode == "observable" {
                results.append("@ObservationIgnored \(raw: space(baseAccess))nonisolated let id: Foundation.UUID = Foundation.UUID()")
            } else {
                results.append("\(raw: space(baseAccess))nonisolated let id: Foundation.UUID = Foundation.UUID()")
            }
        }

        // Always generate inits
        results.append("\(raw: space(baseAccess))init(state: State) { self.state = state; bind() }")
        results.append("\(raw: space(baseAccess))init() { self.state = State(); bind() }")

        if !inheritsFromBase {
            results.append("""
                \(raw: space(baseAccess))final func bind() {
                    bindings.forEach { $0.store(in: &cancelables) }
                }
                """)
        }

        return results
    }

    // MARK: - ExtensionMacro
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let mode = getMode(from: node)

        var conformances = "BaseViewModelProtocol, Identifiable"
        if mode == "observed" {
            conformances += ", SwiftUI.ObservableObject"
        }

        let classHasMainActor = declaration.attributes.contains { attr in
            attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "MainActor"
        }
        let mainActorAttr = classHasMainActor ? "" : "@MainActor\n"

        let extensionDecl: DeclSyntax =
            """
            \(raw: mainActorAttr)extension \(raw: type.trimmedDescription): \(raw: conformances) {}
            """

        guard let extensionDecl = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDecl]
    }

    // MARK: - Helpers
    private static func getMode(from node: AttributeSyntax) -> String {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let modeArg = arguments.first(where: { $0.label?.text == "mode" || $0.label == nil }),
              let memberAccess = modeArg.expression.as(MemberAccessExprSyntax.self) else {
            return "observable" // Default
        }
        return memberAccess.declName.baseName.text
    }
}

enum MacroDiagnostic: Error, DiagnosticMessage {
    case onlyApplicableToClass
    case missingMember(String)

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .onlyApplicableToClass: return "@BaseViewModel can only be applied to a class."
        case .missingMember(let name): return "@BaseViewModel requires a nested '\(name)' definition."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "BMSwiftUIMacros", id: message)
    }
}

@main
struct BMSwiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BaseViewModelMacro.self,
        PreferencesMacro.self,
        ObservedStateMacro.self
    ]
}
