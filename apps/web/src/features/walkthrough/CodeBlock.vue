<script setup lang="ts">
import { computed } from "vue";
import { highlight } from "../../syntax.ts";
import type { Lang } from "../../types.ts";

const props = defineProps<{
  content: string;
  lang: Lang;
  startLine?: number;
}>();

const lines = computed(() => props.content.split("\n"));
const lineCount = computed(() => lines.value.length);
const startAt = computed(() => props.startLine ?? 1);
const lineNumbers = computed(() =>
  Array.from({ length: lineCount.value }, (_, i) => startAt.value + i).join("\n"),
);
const highlighted = computed(() => highlight(props.content, props.lang));
</script>

<template>
  <pre
    class="code"
  ><span class="line-numbers">{{ lineNumbers }}</span><code :class="`lang-${lang}`" v-html="highlighted" /></pre>
</template>

<style scoped>
pre.code {
  margin: 0;
  padding: 16px 16px 80px;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: 16px;
  font-family: var(--font-mono);
  font-size: 13px;
  line-height: 1.65;
  letter-spacing: 0;
  tab-size: 2;
  color: var(--fg);
  white-space: pre;
  min-width: 0;
}

.line-numbers {
  text-align: right;
  color: var(--fg-subtle);
  user-select: none;
  font-variant-numeric: tabular-nums;
  font-size: 12px;
  white-space: pre;
}

code {
  font-family: var(--font-mono);
  background: none;
  padding: 0;
  display: block;
  overflow-x: auto;
}

@media (max-width: 640px) {
  pre.code {
    padding: 14px 14px 40px;
    font-size: 12.5px;
    gap: 12px;
  }
}

:deep(.t-kw) {
  color: var(--syn-kw);
  font-weight: 600;
}
:deep(.t-str) {
  color: var(--syn-str);
}
:deep(.t-num) {
  color: var(--syn-num);
  font-variant-numeric: tabular-nums;
}
:deep(.t-com) {
  color: var(--syn-com);
  font-style: italic;
}
:deep(.t-attr) {
  color: var(--syn-attr);
}
:deep(.t-fn) {
  color: var(--syn-fn);
}
:deep(.t-tag) {
  color: var(--syn-tag);
}
:deep(.t-punct) {
  color: var(--syn-punct);
}
</style>
