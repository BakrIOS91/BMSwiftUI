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
            results.append("public static let shared = \(raw: classDecl.name.text)()")
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
            results.append("public let preferencesChangedSubject = Combine.PassthroughSubject<AnyKeyPath, Never>()")
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
