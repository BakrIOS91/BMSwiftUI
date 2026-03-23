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
        
        // Get mode from macro argument
        let mode = getMode(from: node)
        
        // Only add @Published to 'state' if in .observed mode
        if mode == "observed",
           let varDecl = member.as(VariableDeclSyntax.self),
           let firstBinding = varDecl.bindings.first,
           let identifier = firstBinding.pattern.as(IdentifierPatternSyntax.self),
           identifier.identifier.text == "state" {
            return ["@SwiftUI.Published"]
        }
        
        return []
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
        
        // Check for trigger method
        let hasTrigger = memberList.contains { member in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { return false }
            return funcDecl.name.text == "trigger"
        }
        
        if !hasState {
            context.diagnose(Diagnostic(node: Syntax(node), message: MacroDiagnostic.missingMember("State")))
        }
        if !hasAction {
            context.diagnose(Diagnostic(node: Syntax(node), message: MacroDiagnostic.missingMember("Action")))
        }
        if !hasTrigger {
            context.diagnose(Diagnostic(node: Syntax(node), message: MacroDiagnostic.missingMember("trigger(_:)")))
        }

        return [
            "public var state: State",
            "open var bindings: [Combine.AnyCancellable] { [] }",
            "public var cancelables: Set<Combine.AnyCancellable> = []",
            """
            public init(state: State) {
                self.state = state
                super.init()
                bind()
            }
            """,
            """
            public final func bind() {
                bindings.forEach { $0.store(in: &cancelables) }
            }
            """
        ]
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
        
        let extensionDecl: DeclSyntax = 
            """
            extension \(raw: type.trimmedDescription): \(raw: conformances) {
                public nonisolated var id: Foundation.UUID { Foundation.UUID() }
            }
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
        BaseViewModelMacro.self
    ]
}
