<script setup lang="ts">
import { computed } from "vue";
import { icons } from "../../icons.ts";
import IconButton from "../../primitives/IconButton.vue";
import { sidebar, toggleCollapsed } from "./useSidebar.ts";

const githubIcon = icons.github();
const twitterIcon = icons.twitter();
const panelIcon = icons.panelRight();

const isCollapsed = computed(() => sidebar.collapsed);
</script>

<template>
  <header class="title-bar">
    <div class="title-bar-left">
      <span class="dot dot-r" aria-hidden="true" />
      <span class="dot dot-y" aria-hidden="true" />
      <span class="dot dot-g" aria-hidden="true" />
    </div>
    <div class="title-bar-center">naitokosuke · dotfiles</div>
    <div class="title-bar-right">
      <IconButton
        href="https://twitter.com/naitokosuke"
        target="_blank"
        aria-label="Twitter / @naitokosuke"
      >
        <span v-html="twitterIcon" />
      </IconButton>
      <IconButton
        href="https://github.com/naitokosuke/dotfiles"
        target="_blank"
        aria-label="GitHub repository"
      >
        <span v-html="githubIcon" />
      </IconButton>
      <IconButton
        aria-controls="sidebar"
        :aria-pressed="isCollapsed"
        aria-label="Toggle sidebar (⌘B)"
        title="Toggle sidebar (⌘B)"
        @click="toggleCollapsed"
      >
        <span v-html="panelIcon" />
      </IconButton>
    </div>
  </header>
</template>

<style scoped>
.title-bar {
  grid-area: title;
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  background: var(--bg-titlebar);
  border-bottom: 1px solid var(--border-1);
  padding-inline: 12px;
  user-select: none;
  -webkit-app-region: drag;

  .title-bar-left {
    display: flex;
    align-items: center;
    gap: 8px;
    padding-inline-end: 18px;

    .dot {
      display: block;
      width: 11px;
      height: 11px;
      border-radius: 999px;
      background: var(--border-2);
      transition: background 200ms var(--easing);
    }
  }

  .title-bar-center {
    text-align: center;
    color: var(--fg-muted);
    font-size: 12px;
    letter-spacing: 0.06em;
    text-wrap: balance;
  }

  .title-bar-right {
    display: flex;
    align-items: center;
    gap: 6px;
    -webkit-app-region: no-drag;
  }

  &:hover .dot {
    &.dot-r {
      background: #ff5f57;
    }
    &.dot-y {
      background: #febc2e;
    }
    &.dot-g {
      background: #28c840;
    }
  }
}
</style>
