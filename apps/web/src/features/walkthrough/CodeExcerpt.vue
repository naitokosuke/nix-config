<script setup lang="ts">
import { computed } from "vue";
import type { FileEntry } from "../../types.ts";
import CodeBlock from "./CodeBlock.vue";

const props = defineProps<{
  file: FileEntry;
  range: readonly [number, number];
}>();

const start = computed(() => Math.max(1, props.range[0]));
const end = computed(() => Math.min(props.file.content.split("\n").length, props.range[1]));
const chunk = computed(() => {
  const lines = props.file.content.split("\n");
  return lines.slice(start.value - 1, end.value).join("\n");
});
const caption = computed(() =>
  start.value === end.value ? `line ${start.value}` : `lines ${start.value}–${end.value}`,
);
</script>

<template>
  <figure class="excerpt">
    <figcaption>{{ caption }}</figcaption>
    <div class="excerpt-body">
      <CodeBlock :content="chunk" :lang="file.lang" :start-line="start" />
    </div>
  </figure>
</template>

<style scoped>
.excerpt {
  margin: 0;
  border: 1px solid var(--border-1);
  border-radius: 10px;
  overflow: hidden;
  background: var(--bg-elev-1);

  figcaption {
    padding: 8px 14px;
    font-family: var(--font-mono);
    font-size: 11px;
    letter-spacing: 0.04em;
    color: var(--fg-muted);
    background: var(--bg-elev-1);
    border-bottom: 1px solid var(--border-1);
  }
}

.excerpt-body {
  background: var(--bg);
  overflow-x: auto;

  :deep(pre.code) {
    padding: 14px;
  }
}

@media (max-width: 640px) {
  .excerpt-body :deep(pre.code) {
    padding: 12px;
    font-size: 12px;
  }
}
</style>
