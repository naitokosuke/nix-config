<script setup lang="ts">
import { computed } from "vue";
import { icons } from "../icons.ts";
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
      <a
        class="icon-btn"
        href="https://twitter.com/naitokosuke"
        target="_blank"
        rel="noopener"
        aria-label="Twitter / @naitokosuke"
        v-html="twitterIcon"
      />
      <a
        class="icon-btn"
        href="https://github.com/naitokosuke/dotfiles"
        target="_blank"
        rel="noopener"
        aria-label="GitHub repository"
        v-html="githubIcon"
      />
      <button
        class="icon-btn"
        type="button"
        aria-controls="sidebar"
        :aria-pressed="isCollapsed"
        aria-label="Toggle sidebar (⌘B)"
        title="Toggle sidebar (⌘B)"
        @click="toggleCollapsed"
        v-html="panelIcon"
      />
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

.title-bar-left {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-inline-end: 18px;
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

.dot {
  display: block;
  width: 11px;
  height: 11px;
  border-radius: 999px;
  background: var(--border-2);
  transition: background 200ms var(--easing);
}

.icon-btn {
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  border-radius: 6px;
  color: var(--fg-muted);
  transition:
    color 200ms var(--easing),
    background 200ms var(--easing);

  &:hover {
    background: var(--hover);
    color: var(--fg-strong);
  }

  &[aria-pressed="true"] {
    color: var(--fg-subtle);
    background: var(--hover);
  }
}
</style>
