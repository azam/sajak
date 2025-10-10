package io.azam.sajak.core.parser.tree;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Modifier;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import koopa.core.trees.Tree;

public abstract sealed class Statement extends TreeBase permits ComputeStatement, MoveStatement {
  public static final String NAME = "statement";

  private static final Set<String> subClassNames = collectSubClassNames();

  private static Set<String> collectSubClassNames() {
    Set<String> set = new HashSet<>();
    for (Class<?> cls : Statement.class.getPermittedSubclasses()) {
      try {
        Field nameField = cls.getField("NAME");
        int nameFieldModifiers = nameField.getModifiers();
        if (String.class.equals(nameField.getType())
            && Modifier.isStatic(nameFieldModifiers)
            && Modifier.isPublic(nameFieldModifiers)) {
          String name = (String) nameField.get(null);
          set.add(name);
        }
      } catch (NoSuchFieldException | IllegalAccessException e) {
        // ignore
      }
    }
    return Collections.unmodifiableSet(set);
  }

  public static Statement from(Tree tree) {
    for (Tree child : tree.getChildren()) {
      if (subClassNames.contains(child.getName())) {
        Class<? extends TreeBase> cls = classNames.get(child.getName());
        if (Statement.class.isAssignableFrom(cls)) {
          try {
            return (Statement) cls.getConstructor(Tree.class).newInstance(child);
          } catch (InvocationTargetException
              | InstantiationException
              | IllegalAccessException
              | NoSuchMethodException e) {
            throw new IllegalStateException(e);
          }
        }
      }
    }
    return null;
  }

  protected Statement(Tree tree) {
    super(tree);
  }
}
