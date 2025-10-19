package io.azam.sajak.core.parser.tree;

import java.util.List;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class MoveStatement extends TreeBase implements Statement.SubTypes {
  public static final String NAME = "moveStatement";

  public MoveStatement(Tree tree) {
    super(tree);
  }

  @ToString.Include
  public SourceTypes source() {
    return eitherSubType(SourceTypes.class);
  }

  @ToString.Include
  public Identifier target() {
    return childElement(Identifier.class, Identifier.NAME);
  }

  @ToString.Include
  public List<Identifier> targets() {
    return childElements(Identifier.class, Identifier.NAME);
  }

  public sealed interface SourceTypes permits Corresponding, Literal, Sending {}
}
