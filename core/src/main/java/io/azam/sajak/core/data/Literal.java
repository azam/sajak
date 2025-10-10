package io.azam.sajak.core.data;

import java.math.BigDecimal;

public sealed interface Literal {
  record Alphanumeric(String value) implements Literal {}

  record DBCS(String value) implements Literal {}

  record UTF8(String value) implements Literal {}

  record Numeric(BigDecimal value) implements Literal {}
}
