<script setup lang="ts">
import { icons } from "../../icons.ts";
import SidebarTree from "./SidebarTree.vue";
import { sidebar } from "./useSidebar.ts";

defineProps<{
  activePath: string | null;
}>();

const closeIcon = icons.close({ size: 14 });

function closeMenu(): void {
  sidebar.menuOpen = false;
}
</script>

<template>
  <aside id="sidebar" class="sidebar" aria-label="explorer">
    <span class="sheet-handle" aria-hidden="true" />
    <header class="sidebar-head">
      <span>Explorer</span>
      <button
        class="sidebar-close"
        type="button"
        aria-label="Close menu"
        @click="closeMenu"
        v-html="closeIcon"
      />
    </header>
    <SidebarTree :active-path="activePath" />
  </aside>
</template>

<style scoped>
.sidebar {
  grid-area: sidebar;
  background: var(--bg);
  border-left: 1px solid var(--border-1);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-width: 0;
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

.sidebar-close {
  display: none;
  place-items: center;
  width: 26px;
  height: 26px;
  border-radius: 6px;
  color: var(--fg-muted);
  transition:
    color 180ms var(--easing),
    background 180ms var(--easing);

  &:hover {
    color: var(--fg-strong);
    background: var(--hover);
  }
}

.sheet-handle {
  display: none;
  width: 36px;
  height: 4px;
  border-radius: 999px;
  background: var(--border-2);
  margin: 8px auto 4px;
}
</style>
