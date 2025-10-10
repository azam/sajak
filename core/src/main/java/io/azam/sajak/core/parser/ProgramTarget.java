package io.azam.sajak.core.parser;

import static java.util.Objects.requireNonNull;
import static koopa.core.data.tags.AreaTag.COMMENT;
import static koopa.core.data.tags.AreaTag.PROGRAM_TEXT_AREA;

import java.util.Deque;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.concurrent.atomic.AtomicBoolean;
import koopa.core.data.Data;
import koopa.core.data.Token;
import koopa.core.data.markers.End;
import koopa.core.data.markers.Start;
import koopa.core.targets.Target;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ProgramTarget implements Target {
  private final AtomicBoolean isDone = new AtomicBoolean(false);
  private final Deque<String> route = new ConcurrentLinkedDeque<>();
  private final Deque<Element.ElementBuilder> elements = new ConcurrentLinkedDeque<>();
  private final Deque<String> texts = new ConcurrentLinkedDeque<>();
  private final Deque<Element> comments = new ConcurrentLinkedDeque<>();

  public ProgramTarget() {
    elements.push(Element.builder().type(Element.ROOT));
  }

  private synchronized void reset() {
    isDone.set(false);
    route.clear();
    elements.clear();
    elements.push(Element.builder().type(Element.ROOT));
    texts.clear();
    comments.clear();
  }

  private static Position from(koopa.core.data.Position position) {
    return new Position(
        position.getPositionInFile(), position.getPositionInLine(), position.getLinenumber());
  }

  private static Element.ElementBuilder from(Token token) {
    return Element.builder()
        .start(from(token.getStart()))
        .end(from(token.getEnd()))
        .text(token.getText());
  }

  @Override
  public void push(Data data) {
    switch (data) {
      case Start value -> {
        // log.debug("{} {}", ">".repeat(route.size() + 1), value.getName());
        route.push(value.getName());
        Element.ElementBuilder elem = Element.builder().type(value.getName());
        texts.forEach(elem::text);
        texts.clear();
        comments.forEach(elem::comment);
        comments.clear();
        elements.push(elem);
      }
      case End value -> {
        if (route.isEmpty()) throw new IllegalStateException("invalid marker: " + value.toString());
        else if (route.peek().equals(value.getName())) route.pop();
        if (elements.isEmpty()) throw new IllegalStateException("invalid marker: " + value);
        else {
          Element.ElementBuilder elem = elements.pop();
          texts.forEach(elem::text);
          texts.clear();
          comments.forEach(elem::comment);
          comments.clear();
          if (elements.isEmpty()) throw new IllegalStateException("invalid marker: " + value);
          else elements.peek().child(elem.build());
        }
      }
      case Token value -> {
        if (value.hasTag(PROGRAM_TEXT_AREA)) {
          texts.add(value.getText());
        }
        if (value.hasTag(COMMENT)) {
          comments.add(from(value).type(Element.COMMENT).build());
        }
      }
      default -> {}
    }
  }

  @Override
  public void done() {
    isDone.set(true);
    if (elements.size() > 1) throw new IllegalStateException("invalid marker structure");
  }

  public Element root() {
    if (!isDone.get()) throw new IllegalStateException("parsing is not done");
    return requireNonNull(elements.peek()).build();
  }
}
