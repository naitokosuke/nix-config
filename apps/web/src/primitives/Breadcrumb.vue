<script setup lang="ts">
/**
 * Generic breadcrumb — a horizontal trail of labels joined by a
 * separator. The component owns the layout; callers fill in the
 * separator and (optionally) per-item leading icons via slots.
 *
 * Slots:
 *   - `separator(index)`: the divider between two parts; defaults
 *     to a thin `›`.
 *   - `icon(index, item, last)`: leading icon for a part; emit
 *     nothing for parts that should be label-only.
 */
defineProps<{
  items: ReadonlyArray<string>;
}>();
</script>

<template>
  <nav class="breadcrumb" aria-label="path">
    <template v-for="(item, idx) in items" :key="idx">
      <span v-if="idx > 0" class="bc-sep">
        <slot name="separator" :index="idx">›</slot>
      </span>
      <span class="bc-part" :class="{ last: idx === items.length - 1 }">
        <slot name="icon" :index="idx" :item="item" :last="idx === items.length - 1" />
        {{ item }}
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

@media (max-width: 640px) {
  .breadcrumb {
    padding-inline: 14px;
    font-size: 11.5px;
    overflow-x: auto;
    white-space: nowrap;
  }
}
</style>
