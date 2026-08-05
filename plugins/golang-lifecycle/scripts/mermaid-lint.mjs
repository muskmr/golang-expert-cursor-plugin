#!/usr/bin/env node
/**
 * Structural Mermaid linter tuned for the failure modes that break Go diagrams.
 * Usage:
 *   node scripts/mermaid-lint.mjs [files-or-dirs...]
 *   node scripts/mermaid-lint.mjs --deep [files-or-dirs...]   # also runs mmdc if available
 */
import { promises as fs } from "node:fs";
import path from "node:path";
import process from "node:process";
import { spawnSync } from "node:child_process";
import os from "node:os";

const RESERVED_IDS = new Set([
  "end",
  "graph",
  "subgraph",
  "class",
  "style",
  "click",
  "link",
  "state",
  "o",
  "x",
  "flowchart",
  "gitgraph",
]);

const FLOW_ARROWS = ["-->", "---", "-.->", "==>", "--o", "--x"];
const SEQ_ARROWS = ["->>", "-->>", "-)", "--)", "->>+", "-->>+"];

const args = process.argv.slice(2);
const deep = args.includes("--deep");
const targets = args.filter((a) => a !== "--deep");
if (targets.length === 0) targets.push(".");

const errors = [];
const warnings = [];

function note(kind, file, line, message) {
  const entry = { file, line, message };
  if (kind === "error") errors.push(entry);
  else warnings.push(entry);
}

async function walk(target, out = []) {
  let stat;
  try {
    stat = await fs.stat(target);
  } catch {
    note("error", target, 0, "path does not exist");
    return out;
  }
  if (stat.isFile()) {
    out.push(target);
    return out;
  }
  const entries = await fs.readdir(target, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.name === "node_modules" || entry.name === ".git") continue;
    await walk(path.join(target, entry.name), out);
  }
  return out;
}

function extractMermaidBlocks(content, file) {
  const blocks = [];
  if (file.endsWith(".mmd") || file.endsWith(".mermaid")) {
    blocks.push({ body: content, startLine: 1 });
    return blocks;
  }
  const lines = content.split(/\r?\n/);
  let i = 0;
  while (i < lines.length) {
    if (/^```mermaid\s*$/i.test(lines[i])) {
      const start = i + 1;
      i++;
      const bodyLines = [];
      while (i < lines.length && !/^```\s*$/.test(lines[i])) {
        bodyLines.push(lines[i]);
        i++;
      }
      blocks.push({ body: bodyLines.join("\n"), startLine: start + 1 });
    }
    i++;
  }
  return blocks;
}

function stripComments(body) {
  return body
    .split(/\r?\n/)
    .filter((l) => !/^\s*%%/.test(l))
    .join("\n");
}

function detectType(body) {
  const first = stripComments(body)
    .split(/\r?\n/)
    .map((l) => l.trim())
    .find((l) => l.length > 0);
  if (!first) return { type: null, firstLine: "" };
  if (/^flowchart\b/i.test(first)) return { type: "flowchart", firstLine: first };
  if (/^graph\b/i.test(first)) return { type: "graph", firstLine: first };
  if (/^sequenceDiagram\b/i.test(first)) return { type: "sequence", firstLine: first };
  if (/^stateDiagram-v2\b/i.test(first)) return { type: "state-v2", firstLine: first };
  if (/^stateDiagram\b/i.test(first)) return { type: "state", firstLine: first };
  if (/^erDiagram\b/i.test(first)) return { type: "er", firstLine: first };
  if (/^classDiagram\b/i.test(first)) return { type: "class", firstLine: first };
  if (/^gitGraph\b/i.test(first)) return { type: "gitGraph", firstLine: first };
  if (/^pie\b/i.test(first)) return { type: "pie", firstLine: first };
  if (/^gantt\b/i.test(first)) return { type: "gantt", firstLine: first };
  if (/^journey\b/i.test(first)) return { type: "journey", firstLine: first };
  return { type: null, firstLine: first };
}

function checkBalance(file, startLine, body, type) {
  const lines = body.split(/\r?\n/);
  let subgraph = 0;
  let seqBlocks = 0;
  const activations = new Map();

  lines.forEach((raw, idx) => {
    const line = raw.trim();
    const ln = startLine + idx;
    if (!line || line.startsWith("%%")) return;

    if (/^subgraph\b/.test(line)) subgraph++;
    if (type === "flowchart" || type === "graph") {
      if (/^end\b/.test(line)) subgraph--;
    }
    if (type === "sequence") {
      if (/^(alt|opt|loop|par|critical|rect)\b/.test(line)) seqBlocks++;
      if (/^end\b/.test(line)) seqBlocks--;
      const act = line.match(/^activate\s+(\S+)/);
      if (act) activations.set(act[1], (activations.get(act[1]) || 0) + 1);
      const deact = line.match(/^deactivate\s+(\S+)/);
      if (deact) activations.set(deact[1], (activations.get(deact[1]) || 0) - 1);
    }
  });

  if (subgraph !== 0) {
    note("error", file, startLine, `unbalanced subgraph/end (delta=${subgraph})`);
  }
  if (seqBlocks !== 0) {
    note("error", file, startLine, `unbalanced sequence blocks (delta=${seqBlocks})`);
  }
  for (const [who, n] of activations) {
    if (n !== 0) {
      note("error", file, startLine, `activate/deactivate imbalance for ${who} (delta=${n})`);
    }
  }
}

function checkFlowchart(file, startLine, body) {
  const lines = body.split(/\r?\n/);
  lines.forEach((raw, idx) => {
    const line = raw.trim();
    const ln = startLine + idx;
    if (!line || line.startsWith("%%")) return;

    // Trailing comments on code lines
    if (/[^%]\s+%%/.test(line)) {
      note("warning", file, ln, "trailing %% comment on a statement line; put comments on their own line");
    }

    // Reserved IDs used as nodes: end as a bare token in an edge
    if (/(^|[\s>])end(\s*-->|\s*---|\s*$|[\s;[])/.test(line) && !/^end\b/.test(line)) {
      note("error", file, ln, 'reserved node id "end" — rename to done/finish/exit');
    }

    // Unquoted labels with special chars: Node[Foo (bar)] or Node(Foo: bar)
    const unquoted = line.match(/\b([A-Za-z][\w]*)\s*\[\s*([^\]"]*[\(\),:/][^\]"]*)\s*\]/);
    if (unquoted) {
      note("error", file, ln, `unquoted label with special characters on node ${unquoted[1]}; wrap the label in double quotes`);
    }

    // Wrong arrow family
    for (const a of SEQ_ARROWS) {
      if (line.includes(a)) {
        note("error", file, ln, `sequence arrow "${a}" used inside a flowchart`);
        break;
      }
    }
  });
}

function checkSequence(file, startLine, body) {
  const lines = body.split(/\r?\n/);
  lines.forEach((raw, idx) => {
    const line = raw.trim();
    const ln = startLine + idx;
    if (!line || line.startsWith("%%")) return;
    for (const a of FLOW_ARROWS) {
      // Avoid false positives on -->> which is sequence; FLOW has -->
      if (a === "-->" && (line.includes("->>") || line.includes("-->>"))) continue;
      if (line.includes(a) && !line.includes("->>") && !line.includes("-->>")) {
        // Allow --> only if not present; sequence uses ->> mostly
        if (a === "-->" && line.includes("-->") && !line.includes("->>")) {
          note("warning", file, ln, `flowchart-style arrow "${a}" inside sequenceDiagram`);
        }
      }
    }
  });
}

function lintBlock(file, block) {
  const { body, startLine } = block;
  const { type, firstLine } = detectType(body);
  if (!type) {
    note("error", file, startLine, `missing or unknown diagram type declaration (first line: "${firstLine}")`);
    return;
  }
  if (type === "graph") {
    note("warning", file, startLine, 'prefer "flowchart" over deprecated "graph"');
  }
  if (type === "state") {
    note("error", file, startLine, 'use "stateDiagram-v2", not "stateDiagram"');
  }
  checkBalance(file, startLine, body, type);
  if (type === "flowchart" || type === "graph") checkFlowchart(file, startLine, body);
  if (type === "sequence") checkSequence(file, startLine, body);
}

async function deepCheck(file, block) {
  const mmdc = spawnSync("mmdc", ["--version"], { encoding: "utf8" });
  const bin = mmdc.status === 0 ? "mmdc" : null;
  let resolved = bin;
  if (!resolved) {
    const local = path.resolve(
      path.dirname(new URL(import.meta.url).pathname),
      "../../node_modules/.bin/mmdc"
    );
    // Also check /tmp install used during development
    const candidates = [local, "/tmp/mmdcheck/node_modules/.bin/mmdc"];
    for (const c of candidates) {
      try {
        await fs.access(c);
        resolved = c;
        break;
      } catch {
        /* continue */
      }
    }
  }
  if (!resolved) {
    note("warning", file, block.startLine, "--deep requested but mmdc not found on PATH");
    return;
  }
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "mmd-lint-"));
  const inFile = path.join(tmpDir, "in.mmd");
  const outFile = path.join(tmpDir, "out.svg");
  await fs.writeFile(inFile, block.body);
  const result = spawnSync(resolved, ["-i", inFile, "-o", outFile], { encoding: "utf8" });
  if (result.status !== 0) {
    note(
      "error",
      file,
      block.startLine,
      `mermaid parse failed: ${(result.stderr || result.stdout || "").split("\n").slice(0, 6).join(" | ")}`
    );
  }
  await fs.rm(tmpDir, { recursive: true, force: true });
}

const files = [];
for (const t of targets) {
  const walked = await walk(t);
  for (const f of walked) {
    if (/\.(md|mdx|mdc|markdown|mmd|mermaid)$/i.test(f)) files.push(f);
  }
}

for (const file of files) {
  const content = await fs.readFile(file, "utf8");
  const blocks = extractMermaidBlocks(content, file);
  for (const block of blocks) {
    lintBlock(file, block);
    if (deep) await deepCheck(file, block);
  }
}

for (const w of warnings) {
  console.log(`WARN  ${w.file}:${w.line}  ${w.message}`);
}
for (const e of errors) {
  console.log(`ERROR ${e.file}:${e.line}  ${e.message}`);
}

if (errors.length === 0) {
  console.log(`Mermaid lint passed (${files.length} files, ${warnings.length} warnings).`);
  process.exit(0);
}
console.error(`Mermaid lint failed: ${errors.length} error(s), ${warnings.length} warning(s).`);
process.exit(1);
