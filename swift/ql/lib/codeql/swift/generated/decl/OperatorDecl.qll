// generated by codegen/codegen.py
private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.decl.Decl

class OperatorDeclBase extends Synth::TOperatorDecl, Decl {
  string getName() { result = Synth::convertOperatorDeclToRaw(this).(Raw::OperatorDecl).getName() }
}
