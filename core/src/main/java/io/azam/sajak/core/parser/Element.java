package io.azam.sajak.core.parser;

import java.util.List;
import lombok.Builder;
import lombok.Singular;

@Builder
public record Element(
    Position start,
    Position end,
    String type,
    @Singular List<String> texts,
    @Singular List<Element> children,
    @Singular List<Element> comments) {
  public static final String ROOT = "root";
  public static final String COMMENT = "comment";
}
