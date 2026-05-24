<script setup lang="ts">
import { useRouter } from "@void/vue";
import { computed, onBeforeUnmount, onMounted, watch } from "vue";
import BottomNav from "../features/shell/BottomNav.vue";
import Sidebar from "../features/shell/Sidebar.vue";
import SidebarResizer from "../features/shell/SidebarResizer.vue";
import TabBar from "../features/shell/TabBar.vue";
import TitleBar from "../features/shell/TitleBar.vue";
import { useDirs } from "../features/shell/useDirs.ts";
import { sidebar, toggleCollapsed } from "../features/shell/useSidebar.ts";
import { useTabs } from "../features/shell/useTabs.ts";
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
  <div class="workspace" :class="workspaceClasses">
    <TitleBar />
    <main class="editor">
      <TabBar />
      <div class="editor-content">
        <slot />
      </div>
    </main>
    <Sidebar :active-path="activeFilePath" />
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

    :deep(.sidebar) {
      display: none;
    }

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

  &.menu-open {
    :deep(.sidebar) {
      translate: 0 0;
    }
    .sidebar-backdrop {
      display: block;
    }
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

    :deep(.sidebar) {
      grid-area: unset;
      position: fixed;
      left: 0;
      right: 0;
      top: auto;
      bottom: 0;
      width: 100%;
      height: min(80dvh, 640px);
      z-index: 19;
      border-left: 0;
      border-top: 1px solid var(--border-1);
      border-radius: 18px 18px 0 0;
      background: var(--bg);
      box-shadow: 0 -16px 50px -10px light-dark(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.7));
      padding-bottom: calc(8px + env(safe-area-inset-bottom, 0px));
      translate: 0 110%;
      transition: translate 280ms var(--easing);
      overscroll-behavior: contain;
    }
    :deep(.sidebar .sidebar-head) {
      padding-inline: 18px;
    }
    :deep(.sidebar-resizer) {
      display: none;
    }
    :deep(.sidebar-close) {
      display: inline-grid;
    }
    :deep(.sheet-handle) {
      display: block;
    }
    :deep(.bottom-nav) {
      display: grid;
    }
  }
}
</style>
