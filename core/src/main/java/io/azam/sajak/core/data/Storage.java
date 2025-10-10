package io.azam.sajak.core.data;

import static java.util.Objects.requireNonNull;

import jakarta.annotation.Nonnull;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.function.Supplier;

public record Storage(
    @Nonnull Fields fields,
    @Nonnull Supplier<Charset> nationalCharsetSupplier,
    @Nonnull ByteBuffer buffer) {
  public Storage {
    requireNonNull(fields, "fields must not be null");
    requireNonNull(nationalCharsetSupplier, "nationalCharsetSupplier must not be null");
    requireNonNull(buffer, "buffer must not be null");
  }

  public Storage(@Nonnull Fields fields) {
    this(fields, NationalCharsetProvider::get, initializeBuffer(fields));
  }

  @Nonnull
  private static ByteBuffer initializeBuffer(@Nonnull Fields fields) {
    requireNonNull(fields);
    return ByteBuffer.allocate(1);
  }

  @Nonnull
  public ByteBuffer slice(@Nonnull Field field) {
    requireNonNull(field);
    return null;
  }

  @Nonnull
  public String intoString(@Nonnull Field field) {
    requireNonNull(field);
    return null;
  }

  public void fromString(@Nonnull Field field, String value) {
    requireNonNull(field);
  }
}
