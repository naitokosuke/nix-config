import type { Lang } from "./types.ts";

type TokenKind = "kw" | "str" | "num" | "com" | "attr" | "punct" | "fn" | "tag" | "text";

interface Token {
  readonly kind: TokenKind;
  readonly text: string;
}

const NIX_KEYWORDS = new Set([
  "let",
  "in",
  "rec",
  "if",
  "then",
  "else",
  "with",
  "inherit",
  "import",
  "true",
  "false",
  "null",
  "or",
  "assert",
  "builtins",
]);

const TS_KEYWORDS = new Set([
  "import",
  "from",
  "export",
  "default",
  "const",
  "let",
  "var",
  "function",
  "return",
  "if",
  "else",
  "for",
  "while",
  "of",
  "in",
  "do",
  "switch",
  "case",
  "break",
  "continue",
  "interface",
  "type",
  "class",
  "extends",
  "implements",
  "readonly",
  "public",
  "private",
  "protected",
  "static",
  "new",
  "this",
  "super",
  "void",
  "typeof",
  "as",
  "is",
  "true",
  "false",
  "null",
  "undefined",
  "async",
  "await",
  "try",
  "catch",
  "finally",
  "throw",
  "yield",
  "satisfies",
  "keyof",
  "infer",
  "never",
  "any",
  "unknown",
]);

const escapeMap: Readonly<Record<string, string>> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;",
};

export function escapeHtml(text: string): string {
  return text.replace(/[&<>"']/g, (ch) => escapeMap[ch] ?? ch);
}

function renderTokens(tokens: readonly Token[]): string {
  let out = "";
  for (const token of tokens) {
    if (token.kind === "text") {
      out += escapeHtml(token.text);
    } else {
      out += `<span class="t-${token.kind}">${escapeHtml(token.text)}</span>`;
    }
  }
  return out;
}

function tokenizeNix(src: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;
  const push = (kind: TokenKind, text: string) => {
    if (text.length > 0) tokens.push({ kind, text });
  };

  while (i < src.length) {
    const ch = src[i]!;

    if (ch === "#") {
      const end = src.indexOf("\n", i);
      const stop = end === -1 ? src.length : end;
      push("com", src.slice(i, stop));
      i = stop;
      continue;
    }

    if (ch === "/" && src[i + 1] === "*") {
      const end = src.indexOf("*/", i + 2);
      const stop = end === -1 ? src.length : end + 2;
      push("com", src.slice(i, stop));
      i = stop;
      continue;
    }

    if (ch === '"') {
      let j = i + 1;
      while (j < src.length && src[j] !== '"') {
        if (src[j] === "\\") j += 2;
        else j += 1;
      }
      j = Math.min(j + 1, src.length);
      push("str", src.slice(i, j));
      i = j;
      continue;
    }

    if (ch === "'" && src[i + 1] === "'") {
      let j = i + 2;
      while (j < src.length - 1 && !(src[j] === "'" && src[j + 1] === "'")) j += 1;
      j = Math.min(j + 2, src.length);
      push("str", src.slice(i, j));
      i = j;
      continue;
    }

    if (ch >= "0" && ch <= "9") {
      let j = i + 1;
      while (j < src.length && /[0-9.]/.test(src[j]!)) j += 1;
      push("num", src.slice(i, j));
      i = j;
      continue;
    }

    if (/[A-Za-z_]/.test(ch)) {
      let j = i + 1;
      while (j < src.length && /[A-Za-z0-9_'-]/.test(src[j]!)) j += 1;
      const word = src.slice(i, j);
      if (NIX_KEYWORDS.has(word)) push("kw", word);
      else if (src[j] === "=" && src[j + 1] !== "=") push("attr", word);
      else push("text", word);
      i = j;
      continue;
    }

    if (/[{}[\]();:.,=]/.test(ch)) {
      push("punct", ch);
      i += 1;
      continue;
    }

    push("text", ch);
    i += 1;
  }
  return tokens;
}

function tokenizeTs(src: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;
  const push = (kind: TokenKind, text: string) => {
    if (text.length > 0) tokens.push({ kind, text });
  };

  while (i < src.length) {
    const ch = src[i]!;
    const next = src[i + 1];

    if (ch === "/" && next === "/") {
      const end = src.indexOf("\n", i);
      const stop = end === -1 ? src.length : end;
      push("com", src.slice(i, stop));
      i = stop;
      continue;
    }

    if (ch === "/" && next === "*") {
      const end = src.indexOf("*/", i + 2);
      const stop = end === -1 ? src.length : end + 2;
      push("com", src.slice(i, stop));
      i = stop;
      continue;
    }

    if (ch === '"' || ch === "'" || ch === "`") {
      let j = i + 1;
      while (j < src.length && src[j] !== ch) {
        if (src[j] === "\\") j += 2;
        else j += 1;
      }
      j = Math.min(j + 1, src.length);
      push("str", src.slice(i, j));
      i = j;
      continue;
    }

    if (ch >= "0" && ch <= "9") {
      let j = i + 1;
      while (j < src.length && /[0-9.eE_xXa-fA-F]/.test(src[j]!)) j += 1;
      push("num", src.slice(i, j));
      i = j;
      continue;
    }

    if (/[A-Za-z_$]/.test(ch)) {
      let j = i + 1;
      while (j < src.length && /[A-Za-z0-9_$]/.test(src[j]!)) j += 1;
      const word = src.slice(i, j);
      if (TS_KEYWORDS.has(word)) push("kw", word);
      else if (src[j] === "(") push("fn", word);
      else push("text", word);
      i = j;
      continue;
    }

    push("text", ch);
    i += 1;
  }
  return tokens;
}

function tokenizeJson(src: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;
  const push = (kind: TokenKind, text: string) => {
    if (text.length > 0) tokens.push({ kind, text });
  };

  while (i < src.length) {
    const ch = src[i]!;
    if (ch === '"') {
      let j = i + 1;
      while (j < src.length && src[j] !== '"') {
        if (src[j] === "\\") j += 2;
        else j += 1;
      }
      j = Math.min(j + 1, src.length);
      const isKey = (() => {
        let k = j;
        while (k < src.length && /\s/.test(src[k]!)) k += 1;
        return src[k] === ":";
      })();
      push(isKey ? "attr" : "str", src.slice(i, j));
      i = j;
      continue;
    }
    if (ch === "-" || (ch >= "0" && ch <= "9")) {
      let j = i + 1;
      while (j < src.length && /[0-9.eE+-]/.test(src[j]!)) j += 1;
      push("num", src.slice(i, j));
      i = j;
      continue;
    }
    if (/[A-Za-z]/.test(ch)) {
      let j = i + 1;
      while (j < src.length && /[A-Za-z]/.test(src[j]!)) j += 1;
      const word = src.slice(i, j);
      if (word === "true" || word === "false" || word === "null") push("kw", word);
      else push("text", word);
      i = j;
      continue;
    }
    push("text", ch);
    i += 1;
  }
  return tokens;
}

function highlightMarkdown(src: string): string {
  const lines = src.split("\n");
  return lines
    .map((line) => {
      if (/^\s*#{1,6}\s/.test(line)) return `<span class="t-kw">${escapeHtml(line)}</span>`;
      if (/^\s*[-*+]\s/.test(line) || /^\s*\d+\.\s/.test(line)) {
        const m = line.match(/^(\s*)([-*+]|\d+\.)(\s)(.*)$/);
        if (m)
          return `${escapeHtml(m[1] ?? "")}<span class="t-punct">${escapeHtml(m[2] ?? "")}</span>${escapeHtml(m[3] ?? "")}${inlineMd(m[4] ?? "")}`;
      }
      if (/^\s*>/.test(line)) return `<span class="t-com">${escapeHtml(line)}</span>`;
      if (line.startsWith("```")) return `<span class="t-tag">${escapeHtml(line)}</span>`;
      return inlineMd(line);
    })
    .join("\n");
}

function inlineMd(line: string): string {
  let out = escapeHtml(line);
  out = out.replace(/`([^`]+)`/g, '<span class="t-str">`$1`</span>');
  out = out.replace(/\*\*([^*]+)\*\*/g, '<span class="t-attr">**$1**</span>');
  out = out.replace(
    /\[([^\]]+)\]\(([^)]+)\)/g,
    '<span class="t-fn">[$1]</span><span class="t-punct">($2)</span>',
  );
  return out;
}

export function highlight(content: string, lang: Lang): string {
  switch (lang) {
    case "nix":
      return renderTokens(tokenizeNix(content));
    case "ts":
      return renderTokens(tokenizeTs(content));
    case "json":
      return renderTokens(tokenizeJson(content));
    case "md":
      return highlightMarkdown(content);
    default:
      return escapeHtml(content);
  }
}
