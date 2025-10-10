package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class RecordDescriptionEntry extends TreeBase {
  public static final String NAME = "recordDescriptionEntry";

  public RecordDescriptionEntry(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public DataDescriptionEntry dataDescriptionEntry() {
    return childElement(DataDescriptionEntry.class, DataDescriptionEntry.NAME);
  }
}
