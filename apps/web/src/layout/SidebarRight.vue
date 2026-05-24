<script setup lang="ts">
/**
 * Desktop layout — title bar across the top, editor on the left,
 * a resizable Explorer sidebar pinned to the right edge.
 *
 * The sidebar's width is bound to `useSidebar`'s reactive ref via
 * `--sidebar-w` on the workspace element so the grid template
 * column re-evaluates as the user drags the splitter.
 */
import { computed } from "vue";
import SidebarExplorer from "../features/shell/SidebarExplorer.vue";
import SidebarResizer from "../features/shell/SidebarResizer.vue";
import TabBar from "../features/shell/TabBar.vue";
import TitleBar from "../features/shell/TitleBar.vue";
import { sidebar } from "../features/shell/useSidebar.ts";

defineProps<{
  activePath: string | null;
}>();

const workspaceClasses = computed(() => ({
  "sidebar-collapsed": sidebar.collapsed,
}));

const workspaceStyle = computed(() => ({
  "--sidebar-w": `${sidebar.width}px`,
}));
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
    <SidebarExplorer :active-path="activePath" />
    <SidebarResizer />
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

@media (max-width: 860px) {
  .workspace {
    --sidebar-w: 240px;
  }
}
</style>
