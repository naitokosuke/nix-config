<script setup lang="ts">
import EditorEmpty from "../features/shell/EditorEmpty.vue";
import { useTabs } from "../features/shell/useTabs.ts";
import WelcomeStage from "../features/welcome/WelcomeStage.vue";

const { welcomeOpen } = useTabs();
</script>

<template>
  <WelcomeStage v-if="welcomeOpen" />
  <EditorEmpty v-else />
</template>
