package io.azam.sajak.core.parser.tree;

import java.util.Set;
import koopa.core.trees.Tree;

public abstract sealed class Statement extends TreeBase permits ComputeStatement, MoveStatement {
  public static final String NAME = "statement";

  private static final Set<String> subClassNames = collectSubClassNames(Statement.class);

  public static Statement from(Tree tree) {
    for (Tree child : tree.getChildren()) {
      if (subClassNames.contains(child.getName())) {
        return TreeBase.from(child);
      }
    }
    return null;
  }

  protected Statement(Tree tree) {
    super(tree);
  }
}
