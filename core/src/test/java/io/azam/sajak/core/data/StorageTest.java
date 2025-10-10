package io.azam.sajak.core.data;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import org.junit.jupiter.api.Test;

public class StorageTest {
  @Test
  void testSampleDto() {
    SampleDto dto = new SampleDto();
    assertNotNull(dto);
  }
}
