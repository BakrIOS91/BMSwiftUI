import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservedStateMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Only applicable to struct or class
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            return []
        }
        
        let members = declaration.memberBlock.members
        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        var parameters: [String] = []
        var assignments: [String] = []
        
        for decl in variableDecls {
            for binding in decl.bindings {
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    continue
                }
                
                // Get type or infer from initializer
                let type: String
                if let typeAnnotation = binding.typeAnnotation?.type.trimmedDescription {
                    type = typeAnnotation
                } else if binding.initializer?.value != nil {
                    // Very basic type inference for common types if needed, 
                    // but usually State structs have explicit types or simple defaults.
                    // For now, we'll try to use the initializer's value if type is missing?
                    // Actually, if type is missing, it's hard to generate a parameter.
                    // But in Swift macros, we can't easily get the inferred type.
                    // Let's assume there's a type annotation or a simple default we can ignore.
                    continue 
                } else {
                    continue
                }
                
                let defaultValue = binding.initializer?.value.trimmedDescription
                let parameter = "\(identifier): \(type)\(defaultValue != nil ? " = \(defaultValue!)" : "")"
                parameters.append(parameter)
                assignments.append("self.\(identifier) = \(identifier)")
            }
        }
        
        if assignments.isEmpty {
            return []
        }
        
        let declModifiers: DeclModifierListSyntax
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            declModifiers = structDecl.modifiers
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            declModifiers = classDecl.modifiers
        } else {
            return []
        }
        
        let modifierNames = declModifiers.map { $0.name.text }
        let access: String
        if modifierNames.contains("public") {
            access = "public "
        } else if modifierNames.contains("fileprivate") {
            access = "fileprivate "
        } else if modifierNames.contains("private") {
            access = "private "
        } else {
            access = "internal "
        }
        
        let initDecl: DeclSyntax = """
        \(raw: access)init(\(raw: parameters.joined(separator: ", "))) {
            \(raw: assignments.joined(separator: "\n    "))
        }
        """
        
        return [initDecl]
    }
}
