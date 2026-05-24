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
}

/* `:deep()` rules MUST live outside CSS nesting — Vue's scoped
   CSS compiler combined with native nesting otherwise emits a
   bogus `.workspace [data-v-xxx] .sidebar` selector that never
   matches the primitive's aside (the aside *is* the data-v
   element, not a descendant of one). Keeping them flat compiles
   to `.workspace[data-v-xxx] .sidebar`, which matches as
   intended. */
.workspace :deep(.sidebar) {
  grid-area: sidebar;
}

.workspace.sidebar-collapsed {
  grid-template-columns: 1fr 0px;
}

.workspace.sidebar-collapsed :deep(.sidebar-resizer) {
  right: 0;
  width: 10px;
}
.workspace.sidebar-collapsed :deep(.sidebar-resizer::before) {
  inset: 0 4px;
  background: var(--border-2);
}
.workspace.sidebar-collapsed :deep(.sidebar-resizer:hover::before) {
  background: var(--accent);
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
