package io.azam.sajak.core.parser;

import java.util.function.Function;

public abstract sealed class Result<T, E> permits Result.Ok, Result.Err {
  public abstract boolean isOk();

  public abstract boolean isErr();

  public abstract T ok();

  public abstract T okOr(T other);

  public abstract E err();

  public abstract E errOr(E other);

  public abstract <M> Result<M, E> map(Function<T, M> mapper);

  public abstract <M> Result<T, M> mapErr(Function<E, M> mapper);

  public static final class Ok<T, E> extends Result<T, E> {
    private final T value;

    public Ok(T value) {
      this.value = value;
    }

    @Override
    public boolean isOk() {
      return true;
    }

    @Override
    public boolean isErr() {
      return false;
    }

    @Override
    public T ok() {
      return value;
    }

    @Override
    public T okOr(T other) {
      return value;
    }

    @Override
    public E err() {
      throw new IllegalStateException();
    }

    @Override
    public E errOr(E other) {
      return other;
    }

    @Override
    public <M> Result<M, E> map(Function<T, M> mapper) {
      return new Ok<>(mapper.apply(value));
    }

    @Override
    @SuppressWarnings("unchecked")
    public <M> Result<T, M> mapErr(Function<E, M> mapper) {
      return (Result<T, M>) this;
    }
  }

  public static final class Err<T, E> extends Result<T, E> {
    private final E error;

    public Err(E error) {
      this.error = error;
    }

    @Override
    public boolean isOk() {
      return false;
    }

    @Override
    public boolean isErr() {
      return true;
    }

    @Override
    public T ok() {
      throw new IllegalStateException();
    }

    @Override
    public T okOr(T other) {
      return other;
    }

    @Override
    public E err() {
      return error;
    }

    @Override
    public E errOr(E other) {
      return error;
    }

    @SuppressWarnings("unchecked")
    @Override
    public <M> Result<M, E> map(Function<T, M> mapper) {
      return (Result<M, E>) this;
    }

    @Override
    public <M> Result<T, M> mapErr(Function<E, M> mapper) {
      return new Err<>(mapper.apply(error));
    }
  }
}
