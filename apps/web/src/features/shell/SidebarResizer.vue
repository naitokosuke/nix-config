<script setup lang="ts">
import { useTemplateRef } from "vue";
import {
  DEFAULT_W,
  resetWidth,
  setCollapsed,
  setRawWidth,
  settleWidth,
  sidebar,
  SNAP_W,
} from "./useSidebar.ts";

const resizerRef = useTemplateRef<HTMLDivElement>("resizerRef");

let dragging = false;
let startX = 0;
let startW = 0;
let dragMoved = false;

function onPointerDown(event: PointerEvent): void {
  if (event.button !== 0) return;
  const resizer = resizerRef.value;
  if (!resizer) return;
  dragging = true;
  startX = event.clientX;
  startW = sidebar.collapsed ? 0 : sidebar.width || DEFAULT_W;
  dragMoved = false;
  try {
    resizer.setPointerCapture(event.pointerId);
  } catch {
    /* setPointerCapture can throw if the pointer is already lost. */
  }
  resizer.classList.add("is-active");
  document.body.classList.add("resizing-sidebar");
  event.preventDefault();
}

function onPointerMove(event: PointerEvent): void {
  if (!dragging) return;
  const dx = event.clientX - startX;
  const intended = startW - dx;
  if (Math.abs(dx) > 2) dragMoved = true;
  if (!dragMoved) return;

  // Single threshold: below SNAP_W → closed, otherwise the
  // sidebar follows the pointer's intended width 1:1 so the
  // splitter never appears stranded mid-drag.
  if (intended < SNAP_W) {
    if (!sidebar.collapsed) setCollapsed(true);
  } else {
    if (sidebar.collapsed) setCollapsed(false);
    setRawWidth(intended);
  }
}

function endDrag(event: PointerEvent): void {
  if (!dragging) return;
  dragging = false;

  const resizer = resizerRef.value;
  if (resizer) {
    try {
      if (resizer.hasPointerCapture(event.pointerId)) {
        resizer.releasePointerCapture(event.pointerId);
      }
    } catch {
      /* Capture may already be released — that's fine. */
    }
    resizer.classList.remove("is-active");
  }
  document.body.classList.remove("resizing-sidebar");

  if (!dragMoved) {
    setCollapsed(!sidebar.collapsed);
    return;
  }
  if (!sidebar.collapsed) settleWidth(sidebar.width);
}

function onDoubleClick(): void {
  resetWidth();
}
</script>

<template>
  <div
    ref="resizerRef"
    class="sidebar-resizer"
    data-resize-sidebar
    role="separator"
    aria-orientation="vertical"
    aria-label="Resize sidebar"
    title="Drag to resize · double-click to reset"
    @pointerdown="onPointerDown"
    @pointermove="onPointerMove"
    @pointerup="endDrag"
    @pointercancel="endDrag"
    @lostpointercapture="endDrag"
    @dblclick="onDoubleClick"
  />
</template>

<style scoped>
.sidebar-resizer {
  position: absolute;
  top: var(--titlebar-h);
  bottom: 0;
  right: calc(var(--sidebar-w) - 3px);
  width: 6px;
  z-index: 10;
  cursor: col-resize;
  background: transparent;
  transition: background 160ms var(--easing) 120ms;
  touch-action: none;

  &::before {
    content: "";
    position: absolute;
    inset: 0 2px;
    background: transparent;
    transition: background 160ms var(--easing) 120ms;
  }

  &:hover::before,
  &.is-active::before,
  &:focus-visible::before {
    background: var(--accent);
    transition-delay: 0s;
  }
}
</style>
