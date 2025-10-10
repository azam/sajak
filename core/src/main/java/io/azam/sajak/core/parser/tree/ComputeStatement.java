package io.azam.sajak.core.parser.tree;

import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class ComputeStatement extends Statement {
  public static final String NAME = "computeStatement";

  public ComputeStatement(Tree tree) {
    super(tree);
  }
}
