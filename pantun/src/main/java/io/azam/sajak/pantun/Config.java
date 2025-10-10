package io.azam.sajak.pantun;

import jakarta.annotation.Nonnull;
import lombok.Builder;

import java.nio.file.Path;
import java.util.Collection;

@Builder(buildMethodName = "__build")
public record Config(
    @Nonnull Collection<Path> paths,
    @Nonnull Collection<Path> copybooks,
    @Nonnull Collection<String> resouurcePaths,
    @Nonnull Collection<String> resourceCopybooks,
    @Nonnull Path outputPath,
    @Nonnull String procedurePackage
) {
  public static class ConfigBuilder {
    public Config build() {
      if (procedurePackage == null || procedurePackage.isBlank())
        procedurePackage = "io.azam.sajak.example";
      return __build();
    }
  }
}
