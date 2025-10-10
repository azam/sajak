package io.azam.sajak.core;

import static java.io.File.createTempFile;
import static java.util.Objects.requireNonNull;
import static org.junit.jupiter.api.Assertions.fail;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;

public class TestUtils {
  public static String resourceAsString(String path) {
    return resourceAsString(path, StandardCharsets.UTF_8);
  }

  public static String resourceAsString(String path, Charset cs) {
    requireNonNull(path);
    requireNonNull(cs);
    try (InputStream is = TestUtils.class.getClassLoader().getResourceAsStream(path)) {
      assert is != null;
      return new String(is.readAllBytes(), cs);
    } catch (Exception e) {
      fail(e);
      throw new AssertionError(e);
    }
  }

  public static Path resourceAsPath(String path) {
    return resourceAsFile(path).toPath();
  }

  public static File resourceAsFile(String path) {
    requireNonNull(path);
    try (InputStream in =
        new BufferedInputStream(
            requireNonNull(TestUtils.class.getClassLoader().getResourceAsStream(path)))) {
      File file = createTempFile("test", path);
      file.deleteOnExit();
      try (OutputStream out = new BufferedOutputStream(new FileOutputStream(file))) {
        in.transferTo(out);
      }
      return file;
    } catch (Exception e) {
      fail(e);
      throw new AssertionError(e);
    }
  }
}
