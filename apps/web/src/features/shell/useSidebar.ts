import { reactive } from "vue";

const STORAGE_WIDTH = "naitokosuke-dotfiles:sidebar-w";
const STORAGE_COLLAPSED = "naitokosuke-dotfiles:sidebar-collapsed";

// Single threshold for both directions: cross outward to open at
// this width, cross inward to snap closed. Keeping SNAP_W equal
// to MIN_W eliminates the "decoupled" zone where the cursor moved
// but the sidebar's edge (and therefore the splitter) stayed put.
export const SNAP_W = 140;
export const MIN_W = SNAP_W;
export const DEFAULT_W = 280;

const inBrowser = typeof window !== "undefined" && typeof window.localStorage !== "undefined";

const initialWidth = (() => {
  if (!inBrowser) return DEFAULT_W;
  const stored = Number.parseInt(localStorage.getItem(STORAGE_WIDTH) ?? "", 10);
  return Number.isFinite(stored) ? stored : DEFAULT_W;
})();

export const sidebar = reactive({
  width: initialWidth,
  collapsed: inBrowser && localStorage.getItem(STORAGE_COLLAPSED) === "1",
  menuOpen: false,
});

export function maxWidth(): number {
  if (!inBrowser) return 600;
  return Math.min(680, Math.max(MIN_W, Math.round(window.innerWidth * 0.55)));
}

export function setRawWidth(value: number): number {
  const v = Math.max(0, Math.min(maxWidth(), Math.round(value)));
  sidebar.width = v;
  return v;
}

export function settleWidth(value: number): number {
  const v = Math.max(MIN_W, Math.min(maxWidth(), Math.round(value)));
  sidebar.width = v;
  if (inBrowser) localStorage.setItem(STORAGE_WIDTH, String(v));
  return v;
}

export function setCollapsed(collapsed: boolean): void {
  sidebar.collapsed = collapsed;
  if (inBrowser) localStorage.setItem(STORAGE_COLLAPSED, collapsed ? "1" : "0");
}

export function toggleCollapsed(): void {
  setCollapsed(!sidebar.collapsed);
}

export function resetWidth(): void {
  sidebar.width = DEFAULT_W;
  if (inBrowser) localStorage.removeItem(STORAGE_WIDTH);
  setCollapsed(false);
}
