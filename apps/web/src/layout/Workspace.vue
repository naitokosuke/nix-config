<script setup lang="ts">
/**
 * Top-level app shell. Picks Mobile vs Desktop based on viewport
 * and owns cross-cutting side effects (tab sync on URL change,
 * sidebar ancestor expansion, mobile sheet close, global
 * keyboard shortcuts). The Void `pages/layout.vue` is a thin
 * passthrough into this component.
 */
import { useRouter } from "@void/vue";
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useDirs } from "../features/shell/useDirs.ts";
import { sidebar, toggleCollapsed } from "../features/shell/useSidebar.ts";
import { useTabs } from "../features/shell/useTabs.ts";
import "../style.css";
import Mobile from "./Mobile.vue";
import SidebarRight from "./SidebarRight.vue";

const router = useRouter();
const dirs = useDirs();
const tabs = useTabs();

const currentPath = computed(() => router.path);

const activeFilePath = computed(() => {
  const path = currentPath.value.replace(/^\/+/, "").replace(/\/+$/, "");
  return path === "" ? null : path;
});
const isHome = computed(() => activeFilePath.value === null);

/**
 * Pick the layout based on viewport. Defaults to desktop on the
 * server (no `window`); on the client we hot-swap once we know.
 */
const MOBILE_QUERY = "(max-width: 640px)";
const isMobile = ref(false);
let mql: MediaQueryList | null = null;

function syncIsMobile(): void {
  if (mql) isMobile.value = mql.matches;
}

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

onMounted(() => {
  mql = window.matchMedia(MOBILE_QUERY);
  syncIsMobile();
  mql.addEventListener("change", syncIsMobile);
  document.addEventListener("keydown", onKey);
});

onBeforeUnmount(() => {
  mql?.removeEventListener("change", syncIsMobile);
  document.removeEventListener("keydown", onKey);
});
</script>

<template>
  <Mobile v-if="isMobile" :active-path="activeFilePath" :is-home="isHome">
    <slot />
  </Mobile>
  <SidebarRight v-else :active-path="activeFilePath">
    <slot />
  </SidebarRight>
</template>
