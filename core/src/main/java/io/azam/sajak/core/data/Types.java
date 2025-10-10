package io.azam.sajak.core.data;

public enum Types {
  G,
  X,
  N,
  B,
  SB,
  U9,
  UV9,
  S9,
  SV9,
  ;

  public boolean isNumeric() {
    return this == B || this == SB || this == U9 || this == UV9 || this == S9 || this == SV9;
  }
}
