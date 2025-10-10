package io.azam.sajak.core.program;

import jakarta.annotation.Nonnull;
import lombok.Builder;

@Builder
public record Program(@Nonnull String id) {}
