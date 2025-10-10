package io.azam.sajak.core.data;

import java.nio.ByteBuffer;

public interface Data {
  Field field();

  ByteBuffer bytes();
}
