package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class DataDivision extends TreeBase {
  public static final String NAME = "dataDivision";

  public DataDivision(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public WorkingStorageSection workingStorageSection() {
    return childElement(WorkingStorageSection.class, WorkingStorageSection.NAME);
  }

  @ToString.Include
  public LinkageSection linkageSection() {
    return childElement(LinkageSection.class, LinkageSection.NAME);
  }
}
