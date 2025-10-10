package io.azam.sajak.core.data;

import static io.azam.sajak.core.Prelude.require;
import static java.util.Objects.requireNonNull;

import jakarta.annotation.Nonnull;
import jakarta.annotation.Nullable;
import lombok.Builder;

@Builder
public record Field(
    int level,
    @Nonnull String name,
    @Nonnull Types type,
    int size,
    int scale,
    @Nullable Signs sign,
    int occurs,
    @Nullable Field redefines,
    @Nullable Field dependingOn) {
  public Field {
    require(level > 0, "level must be larger than zero");
    requireNonNull(name, "name must not be null");
    requireNonNull(type, "type must not be null");
    require(type == Types.G || size > 0, "size must be larger than zero");
    require(
        (type != Types.UV9 && type != Types.SV9) || scale >= 0,
        "scale must be larger than or equal to zero");
  }

  public boolean isArray() {
    return occurs != -1;
  }

  public boolean isNotArray() {
    return occurs == -1;
  }

  public boolean isSigned() {
    return this.type == Types.S9 || this.type == Types.SV9 || this.type == Types.SB;
  }

  public boolean isUnsigned() {
    return !this.isSigned();
  }

  public boolean isRedefining() {
    return this.redefines != null;
  }

  public static Field G(int level, @Nonnull String name) {
    return new Field(level, name, Types.G, 0, 0, null, -1, null, null);
  }

  public static Field G(int level, @Nonnull String name, @Nullable Field redefines) {
    return new Field(level, name, Types.G, 0, 0, null, -1, redefines, null);
  }

  public static Field GArray(int level, @Nonnull String name, int occurs) {
    return new Field(level, name, Types.G, 0, 0, null, occurs, null, null);
  }

  public static Field GArray(
      int level, @Nonnull String name, int occurs, @Nullable Field redefines) {
    return new Field(level, name, Types.G, 0, 0, null, occurs, redefines, null);
  }

  public static Field X(int level, @Nonnull String name, int size) {
    return new Field(level, name, Types.X, size, 0, null, -1, null, null);
  }

  public static Field X(int level, @Nonnull String name, int size, @Nullable Field redefines) {
    return new Field(level, name, Types.X, size, 0, null, -1, redefines, null);
  }

  public static Field XArray(int level, @Nonnull String name, int size, int occurs) {
    return new Field(level, name, Types.X, size, 0, null, occurs, null, null);
  }

  public static Field XArray(
      int level, @Nonnull String name, int size, int occurs, @Nullable Field redefines) {
    return new Field(level, name, Types.X, size, 0, null, occurs, redefines, null);
  }

  public static Field N(int level, @Nonnull String name, int size) {
    return new Field(level, name, Types.N, size, 0, null, -1, null, null);
  }

  public static Field N(int level, @Nonnull String name, int size, @Nullable Field redefines) {
    return new Field(level, name, Types.N, size, 0, null, -1, redefines, null);
  }

  public static Field U9(int level, @Nonnull String name, int size) {
    return new Field(level, name, Types.U9, size, 0, null, -1, null, null);
  }

  public static Field U9(int level, @Nonnull String name, int size, @Nullable Field redefines) {
    return new Field(level, name, Types.U9, size, 0, null, -1, redefines, null);
  }

  public static class FieldBuilder {
    public FieldBuilder() {
      this.level = 0;
      this.name = null;
      this.type = null;
      this.size = 0;
      this.scale = 0;
      this.sign = null;
      this.occurs = -1; // non-array
      this.redefines = null;
      this.dependingOn = null;
    }
  }
}
