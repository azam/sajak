package io.azam.sajak.core.data;

import static java.util.Objects.requireNonNull;

import jakarta.annotation.Nonnull;
import jakarta.annotation.Nullable;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.function.Supplier;

public record Fields(
    @Nonnull List<Field> fields,
    @Nonnull Map<Field, List<Field>> groups,
    @Nonnull Supplier<Charset> nationalCharsetSupplier) {
  public Fields {
    requireNonNull(fields);
    requireNonNull(groups);
    requireNonNull(nationalCharsetSupplier);
  }

  public static Fields of(@Nonnull Field... fields) {
    List<Field> recordFields = List.of(fields);
    Map<Field, List<Field>> fieldGroups = generateGroups(recordFields);
    return new Fields(recordFields, fieldGroups, NationalCharsetProvider::get);
  }

  public static Fields of(
      @Nonnull Supplier<Charset> nationalCharsetSupplier, @Nonnull Field... fields) {
    requireNonNull(nationalCharsetSupplier);
    List<Field> recordFields = List.of(fields);
    Map<Field, List<Field>> fieldGroups = generateGroups(recordFields);
    return new Fields(recordFields, fieldGroups, nationalCharsetSupplier);
  }

  private static Map<Field, List<Field>> generateGroups(@Nonnull List<Field> fields) {
    Map<Field, List<Field>> groups = new HashMap<>();
    Stack<Field> parents = new Stack<>();
    Field prev = null;
    for (Field field : fields) {
      if (prev != null) {
        if (field.level() > prev.level()) {
          parents.push(prev);
        } else if (field.level() < prev.level()) {
          while (!parents.isEmpty() && parents.peek().level() >= field.level()) {
            parents.pop();
          }
        }
      }
      if (!parents.isEmpty()) {
        List<Field> children = groups.getOrDefault(parents.peek(), new ArrayList<>());
        children.add(field);
        groups.put(parents.peek(), children);
      }
      prev = field;
    }
    groups
        .entrySet()
        .forEach(entry -> entry.setValue(Collections.unmodifiableList(entry.getValue())));
    return Collections.unmodifiableMap(groups);
  }

  private static List<Node> buildTree(@Nonnull List<Field> fields) {
    List<Node> roots = new ArrayList<>();
    if (fields.isEmpty()) return Collections.emptyList();
    int topLevel = fields.getFirst().level();
    Map<Field, List<Field>> groups = new HashMap<>();
    Stack<Field> parents = new Stack<>();
    Field prev = null;
    for (Field field : fields) {
      if (field.level() < topLevel) throw new IllegalArgumentException("invalid field level");
      if (prev != null) {
        if (field.level() > prev.level()) {
          parents.push(prev);
        } else if (field.level() < prev.level()) {
          while (!parents.isEmpty() && parents.peek().level() >= field.level()) {
            parents.pop();
          }
        }
      }
      if (!parents.isEmpty()) {
        List<Field> children = groups.getOrDefault(parents.peek(), new ArrayList<>());
        children.add(field);
        groups.put(parents.peek(), children);
      }
      prev = field;
    }
    return Collections.unmodifiableList(roots);
  }

  private static final class Node {
    @Nonnull private final Field field;
    @Nullable private final Node parent;
    @Nullable private final List<Node> children;

    private Node(@Nonnull Field field, @Nullable Node parent, @Nullable List<Node> children) {
      this.field = field;
      this.parent = parent;
      this.children = null;
    }
  }
}
