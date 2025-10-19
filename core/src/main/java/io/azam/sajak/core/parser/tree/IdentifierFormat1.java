package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class IdentifierFormat1 extends TreeBase implements Identifier.SubTypes {
  public static final String NAME = "identifier_format1";

  public IdentifierFormat1(@Nonnull Tree tree) {
    super(tree);
  }
}
