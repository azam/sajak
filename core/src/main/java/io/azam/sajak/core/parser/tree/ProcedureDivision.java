package io.azam.sajak.core.parser.tree;

import java.util.List;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class ProcedureDivision extends TreeBase {
  public static final String NAME = "procedureDivision";

  public ProcedureDivision(koopa.core.trees.Tree tree) {
    super(tree);
  }

  @ToString.Include
  public List<Sentence> sentences() {
    return childElements(Sentence.class, Sentence.NAME);
  }
}
