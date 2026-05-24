<script setup lang="ts">
import { Link } from "@void/vue";
import { icons } from "../icons.ts";
import type { TabModel } from "./useTabs.ts";

const props = defineProps<{
  tab: TabModel;
  active: boolean;
}>();

const emit = defineEmits<{
  close: [key: string];
}>();

const closeIcon = icons.close({ size: 12 });

function onClose(event: MouseEvent): void {
  event.preventDefault();
  event.stopPropagation();
  emit("close", props.tab.key);
}

function onAuxClick(event: MouseEvent): void {
  if (event.button !== 1) return;
  event.preventDefault();
  emit("close", props.tab.key);
}
</script>

<template>
  <div class="tab" :class="{ active }" :data-tab-key="tab.key" @auxclick="onAuxClick">
    <Link class="tab-link" :href="tab.href" preserve-scroll>
      <span class="tab-icon" v-html="tab.iconHtml" />
      <span class="tab-name">{{ tab.name }}</span>
    </Link>
    <button
      class="tab-close"
      type="button"
      :aria-label="`Close ${tab.name}`"
      @click="onClose"
      v-html="closeIcon"
    />
  </div>
</template>

<style scoped>
.tab {
  display: flex;
  align-items: stretch;
  height: 100%;
  border-right: 1px solid var(--border-1);
  font-size: 13px;
  color: var(--fg-muted);
  background: var(--bg-elev-1);
  position: relative;
  flex: 0 0 auto;
  max-width: 220px;
  min-width: 0;

  &.active {
    color: var(--fg-strong);
    background: var(--bg);

    &::after {
      content: "";
      position: absolute;
      inset-inline: 0;
      bottom: -1px;
      height: 1px;
      background: var(--bg);
    }

    .tab-close {
      opacity: 1;
    }
  }

  &:hover .tab-close {
    opacity: 1;
  }
}

.tab-link {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  align-items: center;
  column-gap: 8px;
  padding: 0 6px 0 12px;
  min-width: 0;
  flex: 1 1 auto;
  color: inherit;
  text-decoration: none;
}

.tab-icon {
  display: inline-flex;
  align-items: center;
  flex: 0 0 auto;
}

.tab-name {
  font-family: var(--font-mono);
  font-size: 12px;
  letter-spacing: 0.02em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
}

.tab-close {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  margin: auto 8px auto 4px;
  border-radius: 4px;
  color: var(--fg-subtle);
  opacity: 0;
  transition:
    background 140ms var(--easing),
    color 140ms var(--easing),
    opacity 140ms var(--easing);

  &:hover {
    background: var(--hover);
    color: var(--fg-strong);
  }
  &:focus-visible {
    opacity: 1;
  }
}
</style>
