<script setup lang="ts">
import { computed } from "vue";
import { iconForFile, icons } from "../../icons.ts";
import Breadcrumb from "../../primitives/Breadcrumb.vue";

const props = defineProps<{
  path: string;
}>();

const parts = computed(() => props.path.split("/"));
const chevron = icons.chevronRight({ size: 12 });
</script>

<template>
  <Breadcrumb :items="parts">
    <template #separator>
      <span v-html="chevron" />
    </template>
    <template #icon="{ item, last }">
      <span v-if="last" class="bc-icon" v-html="iconForFile(item)" />
    </template>
  </Breadcrumb>
</template>

<style scoped>
.bc-icon {
  display: inline-flex;
  margin-inline-end: 2px;
}
</style>
