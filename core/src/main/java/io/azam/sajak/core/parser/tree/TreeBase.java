package io.azam.sajak.core.parser.tree;

import static java.util.Objects.requireNonNull;

import jakarta.annotation.Nonnull;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import koopa.core.trees.Tree;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@ToString(onlyExplicitlyIncluded = true)
@EqualsAndHashCode
public abstract sealed class TreeBase
    permits CompilationGroup,
        Corresponding,
        DataAddressIdentifier,
        DataDescriptionEntry,
        DataDivision,
        DataName,
        Function,
        IdentificationDivision,
        Identifier,
        IdentifierFormat1,
        IdentifierFormat2,
        IdentifierFormat6,
        LinkageSection,
        Literal,
        ProcedureDivision,
        ProgramDefinition,
        QualifiedDataName,
        Qualifier,
        RecordDescriptionEntry,
        ReferenceModifier,
        Sending,
        Sentence,
        SourceUnit,
        Statement,
        WorkingStorageSection {
  protected static final Map<String, Class<? extends TreeBase>> classNames =
      collectClassNames(TreeBase.class);

  @SuppressWarnings("unchecked")
  private static Map<String, Class<? extends TreeBase>> collectClassNames(
      Class<? extends TreeBase> baseCls) {
    Map<String, Class<? extends TreeBase>> map = new HashMap<>();
    for (Class<?> cls : baseCls.getPermittedSubclasses()) {
      if (baseCls.isAssignableFrom(cls)) {
        try {
          Field nameField = cls.getField("NAME");
          int nameFieldModifiers = nameField.getModifiers();
          if (String.class.equals(nameField.getType())
              && Modifier.isStatic(nameFieldModifiers)
              && Modifier.isPublic(nameFieldModifiers)) {
            String name = (String) nameField.get(null);
            map.put(name, (Class<? extends TreeBase>) cls);
          }
        } catch (NoSuchFieldException | IllegalAccessException e) {
          throw new IllegalStateException(e);
        }
        int clsModifier = cls.getModifiers();
        if (Modifier.isAbstract(clsModifier) && cls.isSealed()) {
          map.putAll(collectClassNames((Class<? extends TreeBase>) cls));
        }
      }
    }
    map.forEach((k, v) -> log.debug("{} -> {}", k, v.getName()));
    return Collections.unmodifiableMap(map);
  }

  private final Tree tree;

  protected Tree tree() {
    return tree;
  }

  protected TreeBase(@Nonnull Tree tree) {
    requireNonNull(tree);
    this.tree = tree;
  }

  protected String text() {
    return tree.getText();
  }

  protected String programText() {
    return tree.getProgramText();
  }

  protected <T extends TreeBase> T childElement(@Nonnull Class<T> cls, String... names) {
    Tree child = child(names);
    if (child == null) return null;
    try {
      Constructor<T> ctor = cls.getConstructor(Tree.class);
      return ctor.newInstance(child);
    } catch (NoSuchMethodException
        | InvocationTargetException
        | InstantiationException
        | IllegalAccessException e) {
      throw new IllegalStateException(e);
    }
  }

  protected <T extends TreeBase> List<T> childElements(@Nonnull Class<T> cls, String... names) {
    List<Tree> children = children(names);
    if (children == null) return null;
    try {
      Constructor<T> ctor = cls.getConstructor(Tree.class);
      List<T> elems = new ArrayList<>();
      for (Tree child : children) {
        elems.add(ctor.newInstance(child));
      }
      return Collections.unmodifiableList(elems);
    } catch (NoSuchMethodException
        | InvocationTargetException
        | InstantiationException
        | IllegalAccessException e) {
      throw new IllegalStateException(e);
    }
  }

  protected Tree child(@Nonnull String... names) {
    Tree child = null;
    for (String name : names) {
      child = (child == null ? tree : child).getChild(name);
      if (child == null) return null;
    }
    return child;
  }

  protected List<Tree> children(@Nonnull String... names) {
    Tree last = tree;
    for (int i = 0; i < names.length; i++) {
      Tree child = last.getChild(names[i]);
      if (child == null) return Collections.emptyList();
      else if (i == names.length - 1) return last.getChildren(names[i]);
      else last = child;
    }
    return Collections.emptyList();
  }

  protected String childProgramText(String... names) {
    Tree child = child(names);
    return child == null ? null : child.getProgramText();
  }

  public void printTree() {
    printTree(null);
  }

  public void printTree(String prefix) {
    printTree(prefix, tree, 1);
  }

  private static void printTree(String prefix, Tree tree, int depth) {
    if (tree == null) return;
    if (prefix == null) log.info("{} {}", ">".repeat(depth), tree.getName());
    else log.info("{} {} {}", prefix, ">".repeat(depth), tree.getName());
    for (Tree child : tree.childTrees()) printTree(prefix, child, depth + 1);
  }
}
