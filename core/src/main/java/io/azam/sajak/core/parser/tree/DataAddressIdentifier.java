package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class DataAddressIdentifier extends TreeBase implements Identifier.SubTypes {
  public static final String NAME = "dataAddressIdentifier";

  public DataAddressIdentifier(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public Identifier identifier() {
    return childElement(Identifier.class, Identifier.NAME);
  }
}
