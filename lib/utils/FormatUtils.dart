import 'package:flutter/material.dart';

enum TokenType {
  objectOpen, // {
  objectClose, // }
  arrayOpen, // [
  arrayClose, // ]
  colon, // :
  comma, // ,
  string, // "..."
  number, // 123, 1.5
  boolNull, // true / false / null
  whitespace, // spaces / tabs / newlines (collapsed)
  unknown, // any other character
}

class Token {
  const Token(this.type, this.value);

  final TokenType type;
  final String value;
}

class Span {
  const Span(this.text, this.color);

  final String text;
  final Color color;
}

// ─── Pretty-printer (reconstructs the exact characters, re-flows indentation) ─
class BeautifyResult {
  const BeautifyResult(this.spans, this.lineCount, this.raw);
  final List<Span> spans;
  final int lineCount;
  final String raw;
}

// Colour palette
const _colBrace = Color(0xFFFFD166); // { } [ ]
const _colKey = Color(0xFF06D6A0); // object keys
const _colString = Color(0xFFEF476F); // string values
const _colNumber = Color(0xFF118AB2); // numbers
const _colBool = Color(0xFFFF9F1C); // true / false / null
const _colColon = Color(0xFFAAAAAA); // :
const _colComma = Color(0xFFAAAAAA); // ,
const _colUnknown = Color(0xFFCCCCCC); // anything else

class FormatUtils {
// ─── Tokeniser (non-destructive — every character is kept) ───────────────────

  List<Token> tokenise(String src) {
    final tokens = <Token>[];
    int i = 0;

    while (i < src.length) {
      final ch = src[i];

      // Structural characters
      if (ch == '{') {
        tokens.add(Token(TokenType.objectOpen, ch));
        i++;
        continue;
      }
      if (ch == '}') {
        tokens.add(Token(TokenType.objectClose, ch));
        i++;
        continue;
      }
      if (ch == '[') {
        tokens.add(Token(TokenType.arrayOpen, ch));
        i++;
        continue;
      }
      if (ch == ']') {
        tokens.add(Token(TokenType.arrayClose, ch));
        i++;
        continue;
      }
      if (ch == ':') {
        tokens.add(Token(TokenType.colon, ch));
        i++;
        continue;
      }
      if (ch == ',') {
        tokens.add(Token(TokenType.comma, ch));
        i++;
        continue;
      }

      // Whitespace — collapse a run into one token so we can re-flow indentation
      if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n') {
        final start = i;
        while (i < src.length &&
            (src[i] == ' ' ||
                src[i] == '\t' ||
                src[i] == '\r' ||
                src[i] == '\n')) {
          i++;
        }
        tokens.add(Token(TokenType.whitespace, src.substring(start, i)));
        continue;
      }

      // String — walk until closing quote, honouring backslash escapes
      if (ch == '"') {
        final buf = StringBuffer(ch);
        i++;
        while (i < src.length) {
          final c = src[i];
          buf.write(c);
          if (c == '\\' && i + 1 < src.length) {
            i++;
            buf.write(src[i]);
          } else if (c == '"') {
            i++;
            break;
          }
          i++;
        }
        tokens.add(Token(TokenType.string, buf.toString()));
        continue;
      }

      // Number — digits, leading minus, decimal point, exponent
      if (ch == '-' || (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57)) {
        final start = i;
        i++;
        while (i < src.length) {
          final c = src[i];
          if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) ||
              c == '.' ||
              c == 'e' ||
              c == 'E' ||
              c == '+' ||
              c == '-') {
            i++;
          } else {
            break;
          }
        }
        tokens.add(Token(TokenType.number, src.substring(start, i)));
        continue;
      }

      // Keywords: true / false / null (and any other identifier-like run)
      if (_isAlpha(ch)) {
        final start = i;
        while (i < src.length && _isAlpha(src[i])) i++;
        final word = src.substring(start, i);
        final type = (word == 'true' || word == 'false' || word == 'null')
            ? TokenType.boolNull
            : TokenType.unknown;
        tokens.add(Token(type, word));
        continue;
      }

      // Anything else — keep verbatim
      tokens.add(Token(TokenType.unknown, ch));
      i++;
    }

    return tokens;
  }

  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        c == '_';
  }

  // ─── Span model for coloured output ─────────────────────────────────────────
  BeautifyResult beautify(List<Token> tokens) {
    final spans = <Span>[];
    int indent = 0;
    int lines = 1;
    const ind = '  '; // 2-space indent

    void newline() {
      spans.add(const Span('\n', _colUnknown));
      lines++;
      if (indent > 0) spans.add(Span(ind * indent, _colUnknown));
    }

    // Whether the next meaningful (non-ws) token is a colon — used to colour
    // keys differently from string values.
    bool nextIsColon(int from) {
      for (int j = from; j < tokens.length; j++) {
        if (tokens[j].type == TokenType.whitespace) continue;
        return tokens[j].type == TokenType.colon;
      }
      return false;
    }

    for (int i = 0; i < tokens.length; i++) {
      final tok = tokens[i];

      switch (tok.type) {
        case TokenType.whitespace:
          // Drop original whitespace; we re-flow it ourselves.
          break;

        case TokenType.objectOpen:
        case TokenType.arrayOpen:
          spans.add(Span(tok.value, _colBrace));
          indent++;
          // Peek: if immediately closed, stay on same line
          final nextMeaningful = _nextMeaningfulToken(tokens, i + 1);
          if (nextMeaningful != null &&
              (nextMeaningful.type == TokenType.objectClose ||
                  nextMeaningful.type == TokenType.arrayClose)) {
            // empty container — will close on same line
          } else {
            newline();
          }
          break;

        case TokenType.objectClose:
        case TokenType.arrayClose:
          indent = (indent - 1).clamp(0, 999);
          // Only insert newline if there was content before this closing bracket
          if (_prevMeaningfulToken(tokens, i - 1) != null &&
              (_prevMeaningfulToken(tokens, i - 1)!.type !=
                      TokenType.objectOpen &&
                  _prevMeaningfulToken(tokens, i - 1)!.type !=
                      TokenType.arrayOpen)) {
            newline();
          }
          spans.add(Span(tok.value, _colBrace));
          break;

        case TokenType.colon:
          spans.add(Span(tok.value, _colColon));
          spans.add(const Span(' ', _colUnknown)); // space after colon
          break;

        case TokenType.comma:
          spans.add(Span(tok.value, _colComma));
          newline();
          break;

        case TokenType.string:
          final isKey = nextIsColon(i + 1);
          spans.add(Span(tok.value, isKey ? _colKey : _colString));
          break;

        case TokenType.number:
          spans.add(Span(tok.value, _colNumber));
          break;

        case TokenType.boolNull:
          spans.add(Span(tok.value, _colBool));
          break;

        case TokenType.unknown:
          spans.add(Span(tok.value, _colUnknown));
          break;
      }
    }
    final raw = spans.map((s) => s.text).join();
    return BeautifyResult(spans, lines, raw);
  }

  Token? _nextMeaningfulToken(List<Token> tokens, int from) {
    for (int i = from; i < tokens.length; i++) {
      if (tokens[i].type != TokenType.whitespace) return tokens[i];
    }
    return null;
  }

  Token? _prevMeaningfulToken(List<Token> tokens, int from) {
    for (int i = from; i >= 0; i--) {
      if (tokens[i].type != TokenType.whitespace) return tokens[i];
    }
    return null;
  }

  // Collapse spans into TextSpan tree
  List<TextSpan> spansToTextSpans(List<Span> spans) {
    return spans
        .map((s) => TextSpan(
              text: s.text,
              style: TextStyle(color: s.color),
            ))
        .toList();
  }
}
