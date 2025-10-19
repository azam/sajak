package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class IdentifierFormat2 extends TreeBase implements Identifier.SubTypes {
  public static final String NAME = "identifier_format2";

  public IdentifierFormat2(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public QualifiedDataName qualifiedDataName() {
    return childElement(QualifiedDataName.class, QualifiedDataName.NAME);
  }
}
