/**
 * @name Resolving XML external entity in user-controlled data
 * @description Parsing user-controlled XML documents and allowing expansion of external entity
 * references may lead to disclosure of confidential data or denial of service.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id java/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-776
 *       external/cwe/cwe-827
 */

import java
import semmle.code.java.security.XmlParsers
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking2
import DataFlow::PathGraph

class SafeSaxSourceFlowConfig extends TaintTracking2::Configuration {
  SafeSaxSourceFlowConfig() { this = "XmlParsers::SafeSAXSourceFlowConfig" }

  override predicate isSource(DataFlow::Node src) { src.asExpr() instanceof SafeSaxSource }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() = any(XmlParserCall parse).getSink()
  }

  override int fieldFlowBranchLimit() { result = 0 }
}

class UnsafeXxeSink extends DataFlow::ExprNode {
  UnsafeXxeSink() {
    not exists(SafeSaxSourceFlowConfig safeSource | safeSource.hasFlowTo(this)) and
    exists(XmlParserCall parse |
      parse.getSink() = this.getExpr() and
      not parse.isSafe()
    )
  }
}

class XxeConfig extends TaintTracking::Configuration {
  XxeConfig() { this = "XXE.ql::XxeConfig" }

  override predicate isSource(DataFlow::Node src) { src instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof UnsafeXxeSink }
}

from DataFlow::PathNode source, DataFlow::PathNode sink, XxeConfig conf
where conf.hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "A $@ is parsed as XML without guarding against external entity expansion.", source.getNode(),
  "user-provided value"
