<script setup lang="ts">
import { Link } from "@void/vue";
import { icons } from "../../icons.ts";
import Tab from "../../primitives/Tab.vue";
import type { TabModel } from "./useTabs.ts";

const props = defineProps<{
  tab: TabModel;
  active: boolean;
}>();

const emit = defineEmits<{
  close: [key: string];
}>();

const closeIcon = icons.close({ size: 12 });

function onAuxClick(event: MouseEvent): void {
  if (event.button !== 1) return;
  event.preventDefault();
  emit("close", props.tab.key);
}
</script>

<template>
  <Tab
    :active="active"
    :close-label="`Close ${tab.name}`"
    @close="emit('close', tab.key)"
    @auxclick="onAuxClick"
  >
    <Link class="tab-link" :href="tab.href" preserve-scroll>
      <span class="tab-icon" v-html="tab.iconHtml" />
      <span class="tab-name">{{ tab.name }}</span>
    </Link>
    <template #close-icon>
      <span v-html="closeIcon" />
    </template>
  </Tab>
</template>

<style scoped>
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
</style>
