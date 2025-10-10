package io.azam.sajak.core.parser.tree;

import jakarta.annotation.Nonnull;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public final class IdentificationDivision extends TreeBase {
  public static final String NAME = "identificationDivision";

  public IdentificationDivision(@Nonnull Tree tree) {
    super(tree);
  }

  @ToString.Include
  public String programName() {
    return child(
            "programIdParagraph",
            "programName",
            "alphanumeric",
            "alphanumericConstant",
            "cobolWord")
        .getProgramText();
  }
}
