<script setup lang="ts">
import { onBeforeUnmount, onMounted, useTemplateRef } from "vue";
import { mountWelcomeCanvas } from "../../canvas-bg.ts";

const canvasRef = useTemplateRef<HTMLCanvasElement>("canvasRef");
let dispose: (() => void) | null = null;

onMounted(() => {
  if (canvasRef.value) dispose = mountWelcomeCanvas(canvasRef.value);
});

onBeforeUnmount(() => {
  dispose?.();
  dispose = null;
});
</script>

<template>
  <canvas ref="canvasRef" aria-hidden="true" />
</template>

<style scoped>
canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}
</style>
