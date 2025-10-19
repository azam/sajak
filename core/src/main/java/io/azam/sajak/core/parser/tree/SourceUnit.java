package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class SourceUnit extends TreeBase {
  public static final String NAME = "sourceUnit";

  public SourceUnit(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public ProgramDefinition programDefinition() {
    return childElement(ProgramDefinition.class, ProgramDefinition.NAME);
  }
}
