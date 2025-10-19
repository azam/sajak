package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class Literal extends TreeBase implements MoveStatement.SourceTypes {
  public static final String NAME = "literal";

  public Literal(@Nonnull Tree tree) {
    super(tree);
  }
}
