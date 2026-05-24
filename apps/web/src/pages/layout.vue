<script setup lang="ts">
import { useRouter } from "@void/vue";
import { computed, onBeforeUnmount, onMounted, watch } from "vue";
import BottomNav from "../layout/BottomNav.vue";
import SidebarResizer from "../layout/SidebarResizer.vue";
import SidebarRight from "../layout/SidebarRight.vue";
import TabBar from "../layout/TabBar.vue";
import TitleBar from "../layout/TitleBar.vue";
import { useDirs } from "../layout/useDirs.ts";
import { sidebar, toggleCollapsed } from "../layout/useSidebar.ts";
import { useTabs } from "../layout/useTabs.ts";
import "../style.css";

const router = useRouter();
const dirs = useDirs();
const tabs = useTabs();

const currentPath = computed(() => router.path);

const activeFilePath = computed(() => {
  const path = currentPath.value.replace(/^\/+/, "").replace(/\/+$/, "");
  if (path.startsWith("file/")) return path.slice("file/".length);
  return null;
});
const isHome = computed(() => activeFilePath.value === null);

const workspaceClasses = computed(() => ({
  "sidebar-collapsed": sidebar.collapsed,
  "menu-open": sidebar.menuOpen,
}));

/**
 * The grid template column and the splitter's `right` position
 * both read `--sidebar-w`. Binding the reactive width here keeps
 * them in sync — drag-to-resize would otherwise update the ref
 * but never the CSS, so the column would refuse to budge.
 */
const workspaceStyle = computed(() => ({
  "--sidebar-w": `${sidebar.width}px`,
}));

watch(
  currentPath,
  (path) => {
    tabs.syncFromPath(path);
    if (activeFilePath.value) dirs.ensureAncestors(activeFilePath.value);
    sidebar.menuOpen = false;
  },
  { immediate: true },
);

function onKey(event: KeyboardEvent): void {
  if (event.key === "Escape" && sidebar.menuOpen) {
    event.preventDefault();
    sidebar.menuOpen = false;
    return;
  }
  if ((event.metaKey || event.ctrlKey) && (event.key === "b" || event.key === "B")) {
    event.preventDefault();
    toggleCollapsed();
    return;
  }
  if ((event.metaKey || event.ctrlKey) && event.key === "w") {
    event.preventDefault();
    tabs.closeTab(tabs.activeKey.value);
  }
}

function onBackdropClick(): void {
  sidebar.menuOpen = false;
}

onMounted(() => {
  document.addEventListener("keydown", onKey);
});

onBeforeUnmount(() => {
  document.removeEventListener("keydown", onKey);
});
</script>

<template>
  <div class="workspace" :class="workspaceClasses" :style="workspaceStyle">
    <TitleBar />
    <main class="editor">
      <TabBar />
      <div class="editor-content">
        <slot />
      </div>
    </main>
    <SidebarRight :active-path="activeFilePath" />
    <button
      class="sidebar-backdrop"
      type="button"
      aria-label="Close menu"
      tabindex="-1"
      @click="onBackdropClick"
    />
    <SidebarResizer />
    <BottomNav :is-home="isHome" />
  </div>
</template>

<style scoped>
.workspace {
  display: grid;
  height: 100dvh;
  grid-template-rows: var(--titlebar-h) 1fr;
  grid-template-columns: 1fr var(--sidebar-w);
  grid-template-areas:
    "title   title"
    "editor  sidebar";
  position: relative;

  &.sidebar-collapsed {
    grid-template-columns: 1fr 0px;

    :deep(.sidebar-resizer) {
      right: 0;
      width: 10px;

      &::before {
        inset: 0 4px;
        background: var(--border-2);
      }
      &:hover::before {
        background: var(--accent);
      }
    }
  }

  &.menu-open .sidebar-backdrop {
    display: block;
  }

  /* Hand the sidebar primitive its grid slot. */
  :deep(.sidebar) {
    grid-area: sidebar;
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

@media (max-width: 860px) {
  .workspace {
    --sidebar-w: 240px;
  }
}

@media (max-width: 640px) {
  .workspace {
    --titlebar-h: 44px;
    --bottomnav-h: 64px;

    grid-template-columns: 1fr;
    grid-template-rows: var(--titlebar-h) 1fr var(--bottomnav-h);
    grid-template-areas:
      "title"
      "editor"
      "bottom";

    /* On mobile the sidebar escapes the grid as a fixed bottom-sheet
       (the Sidebar primitive owns those styles); we just unset the
       grid-area override so it doesn't reserve a row/column. */
    :deep(.sidebar) {
      grid-area: unset;
    }
    :deep(.sidebar-resizer) {
      display: none;
    }
  }
}
</style>
