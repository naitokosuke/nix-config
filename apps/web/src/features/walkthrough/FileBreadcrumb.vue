<script setup lang="ts">
import { computed } from "vue";
import { iconForFile, icons } from "../../icons.ts";

interface Crumb {
  readonly part: string;
  readonly trail: string;
  readonly last: boolean;
  readonly iconHtml: string;
}

const props = defineProps<{
  path: string;
}>();

const chevron = icons.chevronRight({ size: 12 });

const crumbs = computed<Crumb[]>(() => {
  const parts = props.path.split("/");
  return parts.map((part, idx) => {
    const last = idx === parts.length - 1;
    return {
      part,
      trail: parts.slice(0, idx + 1).join("/"),
      last,
      iconHtml: last ? iconForFile(part) : "",
    };
  });
});
</script>

<template>
  <nav class="breadcrumb" aria-label="path">
    <template v-for="(crumb, idx) in crumbs" :key="crumb.trail">
      <span v-if="idx > 0" class="bc-sep" v-html="chevron" />
      <span class="bc-part" :class="{ last: crumb.last }">
        <span v-if="crumb.last" class="bc-icon" v-html="crumb.iconHtml" />
        {{ crumb.part }}
      </span>
    </template>
  </nav>
</template>

<style scoped>
.breadcrumb {
  height: 28px;
  display: flex;
  align-items: center;
  gap: 4px;
  padding-inline: 16px;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--fg-muted);
  background: var(--bg);
  border-bottom: 1px solid var(--border-1);
}

.bc-part {
  display: inline-flex;
  align-items: center;
  gap: 4px;

  &.last {
    color: var(--fg-strong);
  }
}

.bc-sep {
  display: inline-flex;
  align-items: center;
  color: var(--fg-subtle);
}

.bc-icon {
  display: inline-flex;
  margin-inline-end: 2px;
}

@media (max-width: 640px) {
  .breadcrumb {
    padding-inline: 14px;
    font-size: 11.5px;
    overflow-x: auto;
    white-space: nowrap;
  }
}
</style>
