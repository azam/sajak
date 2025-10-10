package io.azam.sajak.core.parser.tree;

import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class MoveStatement extends Statement {
  public static final String NAME = "moveStatement";

  public MoveStatement(Tree tree) {
    super(tree);
  }

  @ToString.Include
  public Identifier identifier() {
    return childElement(Identifier.class, Identifier.NAME);
  }
}
