package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class Sentence extends TreeBase {
  public static final String NAME = "sentence";

  public Sentence(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public Statement statement() {
    return childElement(Statement.class, Statement.NAME);
  }
}
