package io.azam.sajak.core.data;

public class SampleDto {
  private static final class __FIELD {
    private static final Field ID = Field.U9(1, "ID", 3);
    private static final Field NAME = Field.X(1, "NAME", 4);
    private static final Field FLAGS = Field.XArray(1, "FLAGS", 1, 3);
    private static final Field CREATED_AT = Field.G(1, "CREATED_AT");
    private static final Field CREATED_AT_YEAR = Field.U9(3, "CREATED_AT_YEAR", 4);
    private static final Field CREATED_AT_MONTH = Field.U9(3, "CREATED_AT_MONTH", 2);
    private static final Field CREATED_AT_DATE = Field.U9(3, "CREATED_AT_DATE", 2);
  }

  private static final Fields __FIELDS =
      Fields.of(
          () -> NationalCharsetProvider.get(SampleDto.class),
          __FIELD.ID,
          __FIELD.NAME,
          __FIELD.FLAGS,
          __FIELD.CREATED_AT,
          __FIELD.CREATED_AT_YEAR,
          __FIELD.CREATED_AT_MONTH,
          __FIELD.CREATED_AT_DATE);

  protected Storage __storage = new Storage(__FIELDS);

  public String getId() {
    return __storage.intoString(__FIELD.ID);
  }

  public void setId(String value) {
    // __storage.from(__FIELD.ID, value);
  }
}
