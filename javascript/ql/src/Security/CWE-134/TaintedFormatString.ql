/**
 * @name Use of externally-controlled format string
 * @description Using external input in format strings can lead to garbled output.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.3
 * @precision high
 * @id js/tainted-format-string
 * @tags security
 *       external/cwe/cwe-134
 */

import javascript
import semmle.javascript.security.dataflow.TaintedFormatStringQuery
import DataFlow::PathGraph

from Configuration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "$@ flows to here and is used in a format string.",
  source.getNode(), "User-provided value"
