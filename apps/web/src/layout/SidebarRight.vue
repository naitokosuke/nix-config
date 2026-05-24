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
import EditorTabs from "../features/shell/EditorTabs.vue";
import TitleBar from "../features/shell/TitleBar.vue";
import {
  DEFAULT_W,
  resetWidth,
  setCollapsed,
  setRawWidth,
  settleWidth,
  sidebar,
  SNAP_W,
} from "../features/shell/useSidebar.ts";
import SidebarResizer from "../primitives/SidebarResizer.vue";

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
      <EditorTabs />
      <div class="editor-content">
        <slot />
      </div>
    </main>
    <SidebarExplorer :active-path="activePath" />
    <SidebarResizer
      :width="sidebar.width"
      :collapsed="sidebar.collapsed"
      :snap-at="SNAP_W"
      :default-width="DEFAULT_W"
      @update:width="setRawWidth"
      @update:collapsed="setCollapsed"
      @settle="settleWidth"
      @reset="resetWidth"
    />
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

    .editor-content {
      grid-area: content;
      min-width: 0;
      min-height: 0;
      overflow: hidden;
      position: relative;
    }
  }

  /* Position the (position-agnostic) splitter primitive at the
     editor/sidebar seam, and assign the sidebar primitive its
     grid area. Wrapped in `&` to keep the chain anchored to the
     workspace's own data-v attribute (otherwise Vue scoped CSS
     would emit a `.workspace [data-v-xxx] .selector` with an
     extra descendant combinator that never matches). */
  & :deep(.sidebar) {
    grid-area: sidebar;
  }
  & :deep(.sidebar-resizer) {
    position: absolute;
    top: var(--titlebar-h);
    bottom: 0;
    right: calc(var(--sidebar-w) - 3px);
    z-index: 10;
  }

  &.sidebar-collapsed {
    grid-template-columns: 1fr 0px;

    & :deep(.sidebar-resizer) {
      right: 0;
      width: 10px;
    }
    & :deep(.sidebar-resizer::before) {
      inset: 0 4px;
      background: var(--border-2);
    }
    & :deep(.sidebar-resizer:hover::before) {
      background: var(--accent);
    }
  }

  @media (max-width: 860px) {
    --sidebar-w: 240px;
  }
}
</style>
