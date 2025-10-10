package io.azam.sajak.core.parser.tree;

import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class DataDescriptionEntry extends TreeBase {
  public static final String NAME = "dataDescriptionEntry";

  public DataDescriptionEntry(koopa.core.trees.Tree tree) {
    super(tree);
  }

  public boolean isFiller() {
    return "FILLER".equals(childProgramText("entryName"));
  }

  public boolean isCursor() {
    return "CURSOR".equals(childProgramText("entryName"));
  }

  public boolean isData() {
    return child("entryName", "dataName") != null;
  }

  @ToString.Include
  public int levelNumber() {
    return Integer.parseInt(child("levelNumber").getProgramText());
  }

  @ToString.Include
  public String entryName() {
    // entryName : (FILLER | CURSOR | dataName)
    return childProgramText("entryName");
  }

  @ToString.Include
  public String pictureClause() {
    return childProgramText("pictureClause");
  }

  @ToString.Include
  public String valueClause() {
    return childProgramText("valueClause");
  }

  @ToString.Include
  public String usageClause() {
    return childProgramText("usageClause");
  }
}
