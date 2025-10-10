package io.azam.sajak.core.parser;

import static koopa.cobol.sources.SourceFormat.FREE;

import io.azam.sajak.core.parser.tree.CompilationGroup;
import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import koopa.cobol.parser.CobolParser;
import koopa.cobol.parser.ParseResults;
import koopa.cobol.projects.StandardCobolProject;
import koopa.core.parsers.Parse;
import koopa.core.trees.KoopaTreeBuilder;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Singular;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Builder
@Getter
@EqualsAndHashCode
@ToString
@AllArgsConstructor
public class Parser {
  @Singular private final List<Path> copybookPaths;
  @Singular private final Map<Path, Path> pathReplacements;

  @Builder
  public record Result(Element root, @Singular List<Element> errors) {}

  public CompilationGroup parse(Path file) throws IOException {
    StandardCobolProject project = new StandardCobolProject();
    project.setDefaultFormat(FREE);
    project.setDefaultPreprocessing(true);
    copybookPaths.stream().map(Path::toFile).forEachOrdered(project::addCopybookPath);
    CobolParser parser = new CobolParser();
    parser.setProject(project);
    parser.setBuildTrees(true);
    ProgramTarget target = new ProgramTarget();
    try {
      Parse parse = parser.getParseSetup(file.toFile()).to(target);
      ParseResults parseResult = parser.parse(file.toFile(), parse);
      KoopaTreeBuilder koopaTree = parse.getTarget(KoopaTreeBuilder.class);
      Element root = target.root();
      List<Element> errors =
          parse.getMessages().getErrors().stream()
              .map(
                  err ->
                      Element.builder()
                          .start(from(err.getFirst().getStart()))
                          .end(from(err.getFirst().getEnd()))
                          .text(err.getSecond())
                          .build())
              .toList();
      Result res = Result.builder().root(root).errors(errors).build();
      return new CompilationGroup(koopaTree.getTree());
    } catch (IOException e) {
      log.error(e.getMessage(), e);
      throw e;
    }
  }

  public static Position from(koopa.core.data.Position position) {
    return new Position(
        position.getPositionInFile(), position.getPositionInLine(), position.getLinenumber());
  }
}
