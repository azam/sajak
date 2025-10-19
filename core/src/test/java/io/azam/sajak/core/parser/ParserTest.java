package io.azam.sajak.core.parser;

import static io.azam.sajak.core.TestUtils.resourceAsPath;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import io.azam.sajak.core.parser.tree.CompilationGroup;
import io.azam.sajak.core.parser.tree.DataDivision;
import io.azam.sajak.core.parser.tree.IdentificationDivision;
import io.azam.sajak.core.parser.tree.ProcedureDivision;
import io.azam.sajak.core.parser.tree.ProgramDefinition;
import io.azam.sajak.core.parser.tree.Sentence;
import io.azam.sajak.core.parser.tree.SourceUnit;
import io.azam.sajak.core.parser.tree.Statement;
import io.azam.sajak.core.parser.tree.WorkingStorageSection;
import java.io.IOException;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.junitpioneer.jupiter.SetSystemProperty;

@Slf4j
public class ParserTest {
  @Test
  @SetSystemProperty(key = "koopa.encoding", value = "UTF-8")
  public void testHitachi() throws IOException {
    Parser parser = Parser.builder().build();
    CompilationGroup compilationGroup = parser.parse(resourceAsPath("hitachi.cbl"));
    assertNotNull(compilationGroup);
    List<SourceUnit> sourceUnits = compilationGroup.sourceUnits();
    assertNotNull(sourceUnits);
    assertFalse(sourceUnits.isEmpty());
    SourceUnit sourceUnit0 = sourceUnits.get(0);
    assertNotNull(sourceUnit0);
    ProgramDefinition programDefinition0 = sourceUnit0.programDefinition();
    assertNotNull(programDefinition0);
    IdentificationDivision identificationDivision0 = programDefinition0.identityDivision();
    assertNotNull(identificationDivision0);
    assertEquals("SAMPLE_UAP", identificationDivision0.programName());
    DataDivision dataDivision0 = programDefinition0.dataDivision();
    assertNotNull(dataDivision0);
    WorkingStorageSection workingStorageSection0 = dataDivision0.workingStorageSection();
    assertNotNull(workingStorageSection0);
    assertFalse(workingStorageSection0.recordDescriptionEntries().isEmpty());
    ProcedureDivision procedureDivision0 = programDefinition0.procedureDivision();
    assertNotNull(procedureDivision0);
    List<Sentence> sentences = procedureDivision0.sentences();
    assertNotNull(sentences);
    assertNotNull(sentences.getFirst());
    Statement statement0 = sentences.getFirst().statement();
    log.info("{}", compilationGroup);
  }
}
