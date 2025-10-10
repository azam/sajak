package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class Sending extends TreeBase {
  public static final String NAME = "sending";

  public Sending(@Nonnull Tree tree) {
    super(tree);
  }
}
