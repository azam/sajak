package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class Function extends TreeBase {
  public static final String NAME = "function";

  public Function(@Nonnull Tree tree) {
    super(tree);
  }
}
