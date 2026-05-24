<script setup lang="ts">
import TabBar from "../../primitives/TabBar.vue";
import EditorTab from "./EditorTab.vue";
import { useTabs } from "./useTabs.ts";

const { tabs, activeKey, closeTab } = useTabs();
</script>

<template>
  <TabBar>
    <EditorTab
      v-for="tab in tabs"
      :key="tab.key"
      :tab="tab"
      :active="tab.key === activeKey"
      @close="closeTab"
    />
  </TabBar>
</template>
