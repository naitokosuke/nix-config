<script setup lang="ts">
import { Link } from "@void/vue";
import { computed } from "vue";
import { icons } from "../../icons.ts";
import { sidebar, toggleCollapsed } from "./useSidebar.ts";

defineProps<{
  isHome: boolean;
}>();

const explorerIcon = icons.explorer({ size: 20 });
const sparkleIcon = icons.sparkle({ size: 20 });
const githubIcon = icons.github({ size: 20 });

const isMenuActive = computed(() => sidebar.menuOpen);

function openSidebarSheet(): void {
  sidebar.menuOpen = !sidebar.menuOpen;
  if (sidebar.collapsed) toggleCollapsed();
}
</script>

<template>
  <nav class="bottom-nav" aria-label="mobile primary">
    <button
      type="button"
      class="bn-btn"
      :class="{ active: isMenuActive }"
      :aria-pressed="isMenuActive"
      aria-controls="sidebar"
      @click="openSidebarSheet"
    >
      <span v-html="explorerIcon" />
      <span>Files</span>
    </button>
    <Link href="/" class="bn-btn" :class="{ active: isHome }">
      <span v-html="sparkleIcon" />
      <span>Home</span>
    </Link>
    <a class="bn-btn" href="https://github.com/naitokosuke/dotfiles" target="_blank" rel="noopener">
      <span v-html="githubIcon" />
      <span>GitHub</span>
    </a>
  </nav>
</template>

<style scoped>
.bottom-nav {
  display: none;
  grid-area: bottom;
  grid-auto-flow: column;
  grid-auto-columns: 1fr;
  padding: 4px 6px calc(4px + env(safe-area-inset-bottom, 0px));
  background: var(--bg-titlebar);
  border-top: 1px solid var(--border-1);
  z-index: 17;

  .bn-btn {
    display: grid;
    place-items: center;
    align-content: center;
    gap: 4px;
    padding: 8px 4px;
    border-radius: 12px;
    font-family: var(--font-ui);
    font-size: 10.5px;
    letter-spacing: 0.04em;
    color: var(--fg-muted);
    text-decoration: none;
    transition:
      color 180ms var(--easing),
      background 180ms var(--easing),
      scale 180ms var(--easing);

    svg {
      transition: stroke-width 180ms var(--easing);
    }

    &:hover {
      background: var(--hover);
    }
    &:active {
      scale: 0.96;
    }

    &.active {
      color: var(--fg-strong);

      svg {
        stroke-width: 1.8;
      }
    }
  }
}
</style>
