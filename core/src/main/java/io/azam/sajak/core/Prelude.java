package io.azam.sajak.core;

import java.util.Collection;

public class Prelude {
  public static void require(boolean condition) {
    if (!condition) {
      throw new IllegalArgumentException();
    }
  }

  public static void require(boolean condition, String message) {
    if (!condition) {
      throw new IllegalArgumentException(message);
    }
  }

  public static void requireNonEmpty(String value) {
    if (value == null || value.isEmpty()) {
      throw new IllegalArgumentException("value must not be null or empty");
    }
  }

  public static void requireNonEmpty(String value, String message) {
    if (value == null || value.isEmpty()) {
      throw new IllegalArgumentException(message);
    }
  }

  public static void requireNonEmpty(Collection<?> value) {
    if (value == null || value.isEmpty()) {
      throw new IllegalArgumentException("value must not be null or empty");
    }
  }

  public static void requireNonEmpty(Collection<?> value, String message) {
    if (value == null || value.isEmpty()) {
      throw new IllegalArgumentException(message);
    }
  }

  public static void check(boolean condition) {
    if (!condition) {
      throw new IllegalStateException();
    }
  }

  public static void check(boolean condition, String message) {
    if (!condition) {
      throw new IllegalStateException(message);
    }
  }
}
