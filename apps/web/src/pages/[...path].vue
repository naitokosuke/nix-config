<script setup lang="ts">
import { useParams } from "@void/vue";
import { computed } from "vue";
import { filesByPath } from "../data.ts";
import FileWalkthrough from "../features/walkthrough/FileWalkthrough.vue";

const params = useParams<{ path: string | string[] }>();

const filePath = computed(() => {
  const raw = params.path;
  return Array.isArray(raw) ? raw.join("/") : raw;
});

const file = computed(() => filesByPath.get(filePath.value));
</script>

<template>
  <FileWalkthrough v-if="file" :file="file" />
  <div v-else class="not-found">
    <h2>404</h2>
    <p>{{ filePath }} was not found.</p>
    <a class="cta" href="/">Back to home</a>
  </div>
</template>

<style scoped>
.not-found {
  display: grid;
  place-content: center;
  text-align: center;
  height: 100%;
  gap: 12px;

  h2 {
    margin: 0;
    font-size: 72px;
    font-weight: 300;
    color: var(--fg-strong);
    letter-spacing: -0.04em;
  }

  p {
    margin: 0;
    color: var(--fg-muted);
  }
}

.cta {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  border-radius: 8px;
  font-family: var(--font-mono);
  font-size: 12px;
  letter-spacing: 0.04em;
  border: 1px solid var(--border-2);
  color: var(--fg-strong);
  background: transparent;
  text-decoration: none;
  transition:
    background 200ms var(--easing),
    translate 200ms var(--easing);

  &:hover {
    background: var(--hover);
    translate: 0 -1px;
  }
}
</style>
