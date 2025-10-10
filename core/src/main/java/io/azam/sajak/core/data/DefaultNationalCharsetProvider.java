package io.azam.sajak.core.data;

import java.nio.charset.Charset;

public class DefaultNationalCharsetProvider implements NationalCharsetProvider {
  public static final Charset DEFAULT = Charset.forName("IBM037");

  @Override
  public int order() {
    return Integer.MAX_VALUE;
  }

  @Override
  public Charset getDefault() {
    return Singletons.defaultNationalCharset;
  }

  @Override
  public Charset getForClass(Class<?> clazz) {
    return Singletons.defaultNationalCharset;
  }

  @Override
  public Charset getForName(String name) {
    return Singletons.defaultNationalCharset;
  }

  public static Charset defaultNationalCharset() {
    return Singletons.defaultNationalCharset;
  }

  private static final class Singletons {
    private static final Charset defaultNationalCharset = loadDefaultNationalCharset();

    private Singletons() {}

    private static Charset loadDefaultNationalCharset() {
      String name = System.getProperty(PROPKEY_SAJAK_NATIONAL_CHARSET);
      return name != null ? Charset.forName(name, DEFAULT) : DEFAULT;
    }
  }
}
