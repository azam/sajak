package io.azam.sajak.core.parser.tree;

import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class ProgramDefinition extends TreeBase {
  public static final String NAME = "programDefinition";

  public ProgramDefinition(koopa.core.trees.Tree tree) {
    super(tree);
  }

  @ToString.Include
  public IdentificationDivision identityDivision() {
    return childElement(IdentificationDivision.class, IdentificationDivision.NAME);
  }

  @ToString.Include
  public DataDivision dataDivision() {
    return childElement(DataDivision.class, DataDivision.NAME);
  }

  @ToString.Include
  public ProcedureDivision procedureDivision() {
    return childElement(ProcedureDivision.class, ProcedureDivision.NAME);
  }
}
