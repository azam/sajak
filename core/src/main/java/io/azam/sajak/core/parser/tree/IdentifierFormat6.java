package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class IdentifierFormat6 extends TreeBase implements Identifier.SubTypes {
  public static final String NAME = "identifier_format6";

  public IdentifierFormat6(@Nonnull Tree tree) {
    super(tree);
  }
}
