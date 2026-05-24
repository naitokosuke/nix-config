<script setup lang="ts">
/**
 * Generic single tab — a horizontal pill containing a leading
 * (link) area and an optional trailing close button. Active state
 * is reflected via the `active` prop; the close emission lets the
 * caller manage open-tab state.
 *
 * Slots:
 *   - default: the tab body (icon, name, …) — wrapped in a flex row
 *   - `close-icon`: glyph shown inside the close button
 */
defineProps<{
  active?: boolean;
  closeLabel?: string;
}>();
defineEmits<{
  close: [];
}>();
</script>

<template>
  <div class="tab" :class="{ active }">
    <slot />
    <button
      v-if="$slots['close-icon']"
      class="tab-close"
      type="button"
      :aria-label="closeLabel"
      @click.prevent.stop="$emit('close')"
    >
      <slot name="close-icon" />
    </button>
  </div>
</template>

<style scoped>
.tab {
  display: flex;
  align-items: stretch;
  height: 100%;
  border-right: 1px solid var(--border-1);
  font-size: 13px;
  color: var(--fg-muted);
  background: var(--bg-elev-1);
  position: relative;
  flex: 0 0 auto;
  max-width: 220px;
  min-width: 0;

  &.active {
    color: var(--fg-strong);
    background: var(--bg);

    &::after {
      content: "";
      position: absolute;
      inset-inline: 0;
      bottom: -1px;
      height: 1px;
      background: var(--bg);
    }
  }

  &:hover .tab-close,
  &.active .tab-close {
    opacity: 1;
  }
}

.tab-close {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  margin: auto 8px auto 4px;
  border-radius: 4px;
  color: var(--fg-subtle);
  opacity: 0;
  transition:
    background 140ms var(--easing),
    color 140ms var(--easing),
    opacity 140ms var(--easing);

  &:hover {
    background: var(--hover);
    color: var(--fg-strong);
  }
  &:focus-visible {
    opacity: 1;
  }
}
</style>
