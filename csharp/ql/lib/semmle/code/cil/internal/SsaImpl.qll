private import cil
private import semmle.code.csharp.dataflow.internal.SsaImplCommon as SsaImplCommon

private module SsaInput implements SsaImplCommon::InputSig {
  class BasicBlock = CIL::BasicBlock;

  BasicBlock getImmediateBasicBlockDominator(BasicBlock bb) { result = bb.getImmediateDominator() }

  BasicBlock getABasicBlockSuccessor(BasicBlock bb) { result = bb.getASuccessor() }

  class ExitBasicBlock = CIL::ExitBasicBlock;

  class SourceVariable = CIL::StackVariable;

  predicate variableWrite(BasicBlock bb, int i, SourceVariable v, boolean certain) {
    forceCachingInSameStage() and
    exists(CIL::VariableUpdate vu |
      vu.updatesAt(bb, i) and
      v = vu.getVariable() and
      certain = true
    )
  }

  predicate variableRead(BasicBlock bb, int i, SourceVariable v, boolean certain) {
    exists(CIL::ReadAccess ra | bb.getNode(i) = ra |
      ra.getTarget() = v and
      certain = true
    )
  }
}

import SsaImplCommon::Make<SsaInput>

cached
private module Cached {
  private import CIL

  cached
  predicate forceCachingInSameStage() { any() }

  cached
  ReadAccess getARead(Definition def) {
    exists(BasicBlock bb, int i |
      ssaDefReachesRead(_, def, bb, i) and
      result = bb.getNode(i)
    )
  }

  cached
  ReadAccess getAFirstRead(Definition def) {
    exists(BasicBlock bb1, int i1, BasicBlock bb2, int i2 |
      def.definesAt(_, bb1, i1) and
      adjacentDefRead(def, bb1, i1, bb2, i2) and
      result = bb2.getNode(i2)
    )
  }

  cached
  predicate hasAdjacentReads(Definition def, ReadAccess first, ReadAccess second) {
    exists(BasicBlock bb1, int i1, BasicBlock bb2, int i2 |
      first = bb1.getNode(i1) and
      adjacentDefRead(def, bb1, i1, bb2, i2) and
      second = bb2.getNode(i2)
    )
  }

  cached
  Definition getAPhiInput(PhiNode phi) { phiHasInputFromBlock(phi, result, _) }

  cached
  predicate hasLastInputRef(Definition phi, Definition def, BasicBlock bb, int i) {
    lastRefRedef(def, bb, i, phi) and
    def = getAPhiInput(phi)
  }
}

import Cached
