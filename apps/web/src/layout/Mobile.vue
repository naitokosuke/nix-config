<script setup lang="ts">
/**
 * Smartphone-style responsive layout — taller title bar, the
 * editor fills the column, a bottom-nav bar replaces the chrome,
 * and the Explorer slides up from the bottom as a sheet
 * controlled by `sidebar.menuOpen`.
 */
import BottomNav from "../features/shell/BottomNav.vue";
import SidebarExplorer from "../features/shell/SidebarExplorer.vue";
import TabBar from "../features/shell/TabBar.vue";
import TitleBar from "../features/shell/TitleBar.vue";
import { sidebar } from "../features/shell/useSidebar.ts";

defineProps<{
  activePath: string | null;
  isHome: boolean;
}>();

function closeMenu(): void {
  sidebar.menuOpen = false;
}
</script>

<template>
  <div class="workspace" :class="{ 'menu-open': sidebar.menuOpen }">
    <TitleBar />
    <main class="editor">
      <TabBar />
      <div class="editor-content">
        <slot />
      </div>
    </main>
    <SidebarExplorer :active-path="activePath" />
    <button
      class="sidebar-backdrop"
      type="button"
      aria-label="Close menu"
      tabindex="-1"
      @click="closeMenu"
    />
    <BottomNav :is-home="isHome" />
  </div>
</template>

<style scoped>
.workspace {
  --titlebar-h: 44px;
  --bottomnav-h: 64px;

  display: grid;
  height: 100dvh;
  grid-template-columns: 1fr;
  grid-template-rows: var(--titlebar-h) 1fr var(--bottomnav-h);
  grid-template-areas:
    "title"
    "editor"
    "bottom";
  position: relative;

  &.menu-open .sidebar-backdrop {
    display: block;
  }
}

.editor {
  grid-area: editor;
  background: var(--bg);
  display: grid;
  grid-template-rows: 36px 1fr;
  grid-template-areas:
    "tabs"
    "content";
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  container-type: inline-size;
}

.editor-content {
  grid-area: content;
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  position: relative;
}

.sidebar-backdrop {
  display: none;
  position: fixed;
  inset: 0;
  background: light-dark(rgba(0, 0, 0, 0.32), rgba(0, 0, 0, 0.6));
  backdrop-filter: blur(4px);
  z-index: 18;
  border: 0;
  padding: 0;
  cursor: pointer;
  animation: backdrop-in 200ms var(--easing);
}

@keyframes backdrop-in {
  from {
    opacity: 0;
  }
}
</style>
