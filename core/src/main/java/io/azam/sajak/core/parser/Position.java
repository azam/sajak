package io.azam.sajak.core.parser;

import lombok.Builder;

@Builder
public record Position(int file, int line, int lineNumber) {}
