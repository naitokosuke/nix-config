<script setup lang="ts">
/**
 * Interactive dot-grid background. A `<canvas>` filled with a
 * regular grid of dots that ripple toward the pointer. No domain
 * knowledge — drop it on any page that needs a soft animated
 * backdrop.
 */
import { onBeforeUnmount, onMounted, useTemplateRef } from "vue";
import { mountDotGrid } from "./dot-grid.ts";

const canvasRef = useTemplateRef<HTMLCanvasElement>("canvasRef");
let dispose: (() => void) | null = null;

onMounted(() => {
  if (canvasRef.value) dispose = mountDotGrid(canvasRef.value);
});

onBeforeUnmount(() => {
  dispose?.();
  dispose = null;
});
</script>

<template>
  <canvas ref="canvasRef" class="dot-grid" aria-hidden="true" />
</template>

<style scoped>
.dot-grid {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}
</style>
