package io.azam.sajak.core.data;

import java.nio.charset.Charset;
import java.util.Comparator;
import java.util.Objects;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;

public interface NationalCharsetProvider {
  String PROPKEY_SAJAK_NATIONAL_CHARSET = "sajak.national.charset";

  int order();

  Charset getDefault();

  Charset getForClass(final Class<?> clazz);

  Charset getForName(final String name);

  static Charset get() {
    try {
      return ServiceLoader.load(NationalCharsetProvider.class).stream()
          .map(ServiceLoader.Provider::get)
          .sorted(Comparator.comparing(NationalCharsetProvider::order))
          .map(NationalCharsetProvider::getDefault)
          .filter(Objects::nonNull)
          .findFirst()
          .orElse(DefaultNationalCharsetProvider.defaultNationalCharset());
    } catch (ServiceConfigurationError e) {
      return DefaultNationalCharsetProvider.defaultNationalCharset();
    }
  }

  static Charset get(final Class<?> clazz) {
    try {
      return ServiceLoader.load(NationalCharsetProvider.class).stream()
          .map(ServiceLoader.Provider::get)
          .sorted(Comparator.comparing(NationalCharsetProvider::order))
          .map(prov -> prov.getForClass(clazz))
          .filter(Objects::nonNull)
          .findFirst()
          .orElse(DefaultNationalCharsetProvider.defaultNationalCharset());
    } catch (ServiceConfigurationError e) {
      return DefaultNationalCharsetProvider.defaultNationalCharset();
    }
  }

  static Charset get(final String name) {
    try {
      return ServiceLoader.load(NationalCharsetProvider.class).stream()
          .map(ServiceLoader.Provider::get)
          .sorted(Comparator.comparing(NationalCharsetProvider::order))
          .map(prov -> prov.getForName(name))
          .filter(Objects::nonNull)
          .findFirst()
          .orElse(DefaultNationalCharsetProvider.defaultNationalCharset());
    } catch (ServiceConfigurationError e) {
      return DefaultNationalCharsetProvider.defaultNationalCharset();
    }
  }
}
