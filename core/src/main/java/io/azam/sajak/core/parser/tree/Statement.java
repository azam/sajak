package io.azam.sajak.core.parser.tree;

import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class Statement extends TreeBase {
  public static final String NAME = "statement";

  public Statement(Tree tree) {
    super(tree);
  }

  @ToString.Include
  public SubTypes subType() {
    return eitherSubType(SubTypes.class);
  }

  public sealed interface SubTypes extends TreeType permits ComputeStatement, MoveStatement {}
}
