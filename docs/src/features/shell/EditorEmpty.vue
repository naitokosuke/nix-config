<script setup lang="ts">
import Logo from "../../primitives/Logo.vue";
</script>

<template>
  <div class="editor-empty" aria-hidden="true">
    <Logo class="empty-logo" variant="nix" />
  </div>
</template>

<style scoped>
.editor-empty {
  display: grid;
  place-content: center;
  height: 100%;
  width: 100%;

  .empty-logo {
    width: clamp(180px, 28vmin, 360px);
    aspect-ratio: 1;
    color: light-dark(rgba(0, 0, 0, 0.085), rgba(255, 255, 255, 0.075));

    :deep(.rotor) {
      animation: empty-logo-spin 240s linear infinite;
    }
  }
}

@keyframes empty-logo-spin {
  to {
    rotate: 360deg;
  }
}
</style>
