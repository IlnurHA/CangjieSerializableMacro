macro package serialization.macros

import std.ast.*
import std.collection.{ArrayList, collectArrayList, filter, map}


func getDeclsToSerialize(
        decls: ArrayList<Decl>,
        excludedFields: ArrayList<String>,
        includedProps: ArrayList<String>
    ): ArrayList<Decl> {
    let filterFunc: (Decl) -> Bool = {
        x => match (x) {
            case varDecl : VarDecl => !excludedFields.contains(varDecl.identifier.value)
            case propDecl : PropDecl => includedProps.contains(propDecl.identifier.value)
            case _ => false
        }
    }

    decls |> filter(filterFunc) |> collectArrayList
}

enum FieldType {
    | Regular
    | Complex
}

func getFieldType(nodeType: TypeNode): FieldType {
    if (let Some(_) <- (nodeType as PrimitiveType)) {
        return FieldType.Regular
    }

    if (let Some(refType) <- (nodeType as RefType)) {
        if (refType.identifier.value == "String") { return FieldType.Regular }
        return FieldType.Complex
    }

    return FieldType.Regular
}

func getFieldForDecl(decl: Decl): Tokens {
    let declName = decl.identifier
    
    let declType = match(decl) {
        case varDecl : VarDecl => varDecl.declType
        case propDecl : PropDecl => propDecl.declType
        case _ => throw Exception("Unexpected decl type: ${decl.identifier.value}")
    }

    match(getFieldType(declType)) {
        case FieldType.Complex => quote($(declName.value): \${this.$(declName).toJsonString()})
        case _ =>
            let declStringLiteral = Token(TokenKind.STRING_LITERAL, "${quote(\${this.$declName})}")
            quote($(declName.value): $(declStringLiteral))
    }
}

func generateExtend(className: Token, decls: ArrayList<Decl>): Tokens {
    let fields = Tokens()

    for ((index, fieldToken) in (decls |> map(getFieldForDecl)).enumerate() where fieldToken.size != 0) {
        if (index != 0) { fields.append(quote(,)) }
        fields.append(fieldToken)
    }

    let bodyToken = Token(TokenKind.STRING_LITERAL,"{${fields}}")

    quote(
extend $className {
    public func toJsonString(): String {
        $bodyToken
    }
}
    )
}

public macro Serialize(classTokens: Tokens): Tokens {
    let classDecl: ClassDecl = (parseDecl(classTokens, astKind: "class_decl") as ClassDecl).getOrThrow()
    
    // Get fields
    let excludedFields = getChildMessages("SerializationExcludeField") |> map { x => x.getString("serializationExcludedField") } |> collectArrayList
    let includedProps = getChildMessages("SerializationIncludeProperty") |> map { x => x.getString("serializationIncludedProp") } |> collectArrayList
    let declsSerialize = getDeclsToSerialize(classDecl.body.decls, excludedFields, includedProps)

    // Generate toJsonString()
    let result = classTokens
    result.append(generateExtend(classDecl.identifier, declsSerialize))

    result
}

public macro SerializationExcludeField(varDeclTokens: Tokens): Tokens {
    assertParentContext("Serialize")

    let varDecl: VarDecl = (parseDecl(varDeclTokens, astKind: "var_decl") as VarDecl).getOrThrow()
    setItem("serializationExcludedField", varDecl.identifier.value)

    return varDeclTokens
}

public macro SerializationIncludeProperty(varDeclTokens: Tokens): Tokens {
    assertParentContext("Serialize")

    let varDecl: PropDecl = (parseDecl(varDeclTokens, astKind: "prop_decl") as PropDecl).getOrThrow()
    setItem("serializationIncludedProp", varDecl.identifier.value)

    return varDeclTokens
}