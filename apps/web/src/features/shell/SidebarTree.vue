<script setup lang="ts">
import { tree } from "../../data.ts";
import { icons } from "../../icons.ts";
import TreeNode from "./TreeNode.vue";

defineProps<{
  activePath: string | null;
}>();

const chevron = icons.chevronRight({ size: 12 });
</script>

<template>
  <div class="sidebar-section">
    <button class="sidebar-section-head" type="button" aria-expanded="true">
      <span class="tree-chevron open" v-html="chevron" />
      <span>dotfiles</span>
    </button>
    <div class="tree">
      <TreeNode
        v-for="child in tree.children"
        :key="child.path + child.type"
        :node="child"
        :depth="1"
        :active-path="activePath"
      />
    </div>
  </div>
</template>

<style scoped>
.sidebar-section {
  flex: 1 1 auto;
  overflow: auto;
  padding-block: 4px 32px;

  .sidebar-section-head {
    width: 100%;
    height: 22px;
    display: flex;
    align-items: center;
    gap: 4px;
    padding-inline: 8px;
    color: var(--fg-strong);
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;

    .tree-chevron {
      display: grid;
      place-items: center;
      color: var(--fg-subtle);

      &.open {
        rotate: 90deg;
      }
    }
  }

  .tree {
    padding-block: 4px;
  }
}
</style>
