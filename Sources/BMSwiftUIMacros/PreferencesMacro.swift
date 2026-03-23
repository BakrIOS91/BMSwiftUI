import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PreferencesMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let members = classDecl.memberBlock.members
        
        let modifiers = classDecl.modifiers.map { $0.as(DeclModifierSyntax.self)?.name.text ?? "" }
        let isPublic = modifiers.contains("public") || modifiers.contains("open")
        let isFilePrivate = modifiers.contains("fileprivate")
        let isPrivate = modifiers.contains("private")

        let baseAccess: String
        if isPublic {
            baseAccess = "public"
        } else if isFilePrivate {
            baseAccess = "fileprivate"
        } else if isPrivate {
            baseAccess = "private"
        } else {
            baseAccess = "" // internal
        }
        
        let space = { (s: String) in s.isEmpty ? "" : s + " " }

        var results: [DeclSyntax] = []
        
        // Add shared property if not exists
        let hasShared = members.contains { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { return false }
            return varDecl.bindings.contains { binding in
                if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                    return identifier.identifier.text == "shared"
                }
                return false
            }
        }
        
        if !hasShared {
            results.append("\(raw: space(baseAccess))static let shared = \(raw: classDecl.name.text)()")
        }
        
        // Add preferencesChangedSubject if not exists
        let hasSubject = members.contains { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { return false }
            return varDecl.bindings.contains { binding in
                if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                    return identifier.identifier.text == "preferencesChangedSubject"
                }
                return false
            }
        }
        
        if !hasSubject {
            results.append("\(raw: space(baseAccess))let preferencesChangedSubject = Combine.PassthroughSubject<AnyKeyPath, Never>()")
        }
        
        return results
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDecl: DeclSyntax = 
            """
            extension \(raw: type.trimmedDescription): PreferencesStore {}
            """
        
        guard let extensionDecl = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }
        
        return [extensionDecl]
    }
}
