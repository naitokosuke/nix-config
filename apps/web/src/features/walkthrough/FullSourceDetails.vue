<script setup lang="ts">
import { computed } from "vue";
import CodeBlock from "../../primitives/CodeBlock.vue";
import { highlight } from "../../syntax.ts";
import type { FileEntry } from "../../types.ts";

const props = defineProps<{
  file: FileEntry;
}>();

const lineCount = computed(() => props.file.content.split("\n").length);
const html = computed(() => highlight(props.file.content, props.file.lang));
</script>

<template>
  <details class="full-source">
    <summary>
      <span class="full-source-summary">View the complete file</span>
      <span class="full-source-meta">{{ lineCount }} lines · {{ file.name }}</span>
    </summary>
    <div class="code-scroller">
      <CodeBlock :html="html" :line-count="lineCount" :lang-class="`lang-${file.lang}`" />
    </div>
  </details>
</template>

<style scoped>
.full-source {
  border: 1px solid var(--border-1);
  border-radius: 10px;
  background: var(--bg-elev-1);
  overflow: hidden;

  summary {
    list-style: none;
    cursor: pointer;
    padding: 12px 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    user-select: none;
    transition: background 180ms var(--easing);

    &::-webkit-details-marker {
      display: none;
    }
    &:hover {
      background: var(--hover);
    }
  }

  &[open] .full-source-summary::before {
    rotate: 90deg;
  }

  .code-scroller {
    border-top: 1px solid var(--border-1);
    background: var(--bg);
    max-height: 70dvh;
    overflow: auto;
  }
}

.full-source-summary {
  font-family: var(--font-mono);
  font-size: 12px;
  letter-spacing: 0.04em;
  color: var(--fg-strong);
  display: inline-flex;
  align-items: center;
  gap: 8px;

  &::before {
    content: "▸";
    display: inline-block;
    font-size: 10px;
    color: var(--fg-muted);
    transition: rotate 180ms var(--easing);
  }
}

.full-source-meta {
  font-family: var(--font-mono);
  font-size: 11px;
  color: var(--fg-muted);
}
</style>
