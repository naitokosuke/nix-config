<script setup lang="ts">
/**
 * Generic Sidebar primitive — no business logic.
 *
 * Positioning + sliding behaviour for a vertical side panel. On
 * desktop it is a static column flanked by a 1px border; on
 * narrow viewports it becomes a bottom-sheet drawer that the
 * parent toggles via the `open` prop.
 *
 * The component does not own its width — layout-level
 * containers set `--sidebar-w` on an ancestor and place this
 * primitive into a grid cell sized to that variable.
 *
 * Slots:
 *   - `handle` — drag-handle shown above the head on mobile.
 *   - `head`   — small uppercased header bar.
 *   - default  — main scrollable body content.
 */
defineProps<{
  /** Which edge of the viewport the sidebar lives on. */
  side?: "left" | "right";
  /** Hide the sidebar entirely (also collapses its layout slot). */
  collapsed?: boolean;
  /** Mobile drawer open state. Ignored on desktop. */
  open?: boolean;
}>();
</script>

<template>
  <aside class="sidebar" :class="[side ?? 'right', { collapsed, open }]" aria-label="sidebar">
    <span v-if="$slots.handle" class="sidebar-handle">
      <slot name="handle" />
    </span>
    <header v-if="$slots.head" class="sidebar-head">
      <slot name="head" />
    </header>
    <div class="sidebar-body">
      <slot />
    </div>
  </aside>
</template>

<style scoped>
@import "../breakpoints.css";

.sidebar {
  background: var(--bg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-width: 0;

  .sidebar-handle {
    display: none;
  }

  .sidebar-head {
    height: 36px;
    padding-inline: 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 11px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--fg-muted);
    border-bottom: 1px solid transparent;
  }

  .sidebar-body {
    flex: 1 1 auto;
    overflow: auto;
    min-height: 0;
  }

  &.left {
    border-right: 1px solid var(--border-1);
  }

  &.right {
    border-left: 1px solid var(--border-1);
  }

  &.collapsed {
    display: none;
  }

  @media (--phone) {
    position: fixed;
    left: 0;
    right: 0;
    top: auto;
    bottom: 0;
    width: 100%;
    height: min(80dvh, 640px);
    z-index: 19;
    border: 0;
    border-top: 1px solid var(--border-1);
    border-radius: 18px 18px 0 0;
    padding-bottom: calc(8px + env(safe-area-inset-bottom, 0px));
    box-shadow: 0 -16px 50px -10px light-dark(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.7));
    translate: 0 110%;
    transition: translate 280ms var(--easing);
    overscroll-behavior: contain;

    .sidebar-handle {
      display: block;
      width: 36px;
      height: 4px;
      border-radius: 999px;
      background: var(--border-2);
      margin: 8px auto 4px;
    }

    .sidebar-head {
      padding-inline: 18px;
    }

    /* On mobile the sidebar is a bottom-sheet drawer; the desktop
       `collapsed` flag (used as a "hide" toggle) is meaningless. */
    &.collapsed {
      display: flex;
    }

    &.open {
      translate: 0 0;
    }
  }
}
</style>
