package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class CobolWord extends TreeBase {
  public static final String NAME = "cobolWord";

  public CobolWord(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  @Override
  public String programText() {
    return super.programText();
  }
}
