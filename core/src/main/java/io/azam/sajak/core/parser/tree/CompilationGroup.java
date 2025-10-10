package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import java.util.List;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class CompilationGroup extends TreeBase {
  public static final String NAME = "compilationGroup";

  public CompilationGroup(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public List<SourceUnit> sourceUnits() {
    return childElements(SourceUnit.class, SourceUnit.NAME);
  }
}
