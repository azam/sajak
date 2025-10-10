package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import java.util.List;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class WorkingStorageSection extends TreeBase {
  public static final String NAME = "workingStorageSection";

  public WorkingStorageSection(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public List<RecordDescriptionEntry> recordDescriptionEntries() {
    return childElements(RecordDescriptionEntry.class, RecordDescriptionEntry.NAME);
  }
}
