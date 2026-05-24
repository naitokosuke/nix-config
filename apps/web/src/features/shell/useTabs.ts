import { computed, reactive, type ComputedRef } from "vue";
import { useRouter } from "@void/vue";
import { filesByPath } from "../../data.ts";
import { iconForFile, icons } from "../../icons.ts";

export const WELCOME_KEY = "__welcome__";

export interface TabModel {
  readonly key: string;
  readonly name: string;
  readonly iconHtml: string;
  readonly href: string;
  readonly isWelcome: boolean;
}

const state = reactive({
  openFiles: [] as string[],
  welcomeOpen: true,
});

function hrefForFile(path: string): string {
  return `/${path}`;
}

function activeKeyFromPath(pathname: string): string {
  const trimmed = pathname.replace(/^\/+/, "").replace(/\/+$/, "");
  if (trimmed === "") return WELCOME_KEY;
  return trimmed;
}

export function useTabs(): {
  tabs: ComputedRef<TabModel[]>;
  activeKey: ComputedRef<string>;
  welcomeOpen: ComputedRef<boolean>;
  syncFromPath: (pathname: string) => void;
  closeTab: (key: string) => void;
} {
  const router = useRouter();

  const activeKey = computed(() => activeKeyFromPath(router.path));
  const welcomeOpen = computed(() => state.welcomeOpen);

  const tabs = computed<TabModel[]>(() => {
    const list: TabModel[] = [];
    if (state.welcomeOpen) {
      list.push({
        key: WELCOME_KEY,
        name: "Welcome",
        iconHtml: icons.sparkle({ size: 14 }),
        href: "/",
        isWelcome: true,
      });
    }
    for (const path of state.openFiles) {
      const file = filesByPath.get(path);
      if (!file) continue;
      list.push({
        key: file.path,
        name: file.name,
        iconHtml: iconForFile(file.name),
        href: hrefForFile(file.path),
        isWelcome: false,
      });
    }
    return list;
  });

  const syncFromPath = (pathname: string) => {
    const key = activeKeyFromPath(pathname);
    if (key === WELCOME_KEY) return;
    if (!filesByPath.has(key)) return;
    if (!state.openFiles.includes(key)) state.openFiles.push(key);
  };

  const closeTab = (key: string) => {
    const active = activeKey.value;

    let neighbour: string | null = null;
    if (key === WELCOME_KEY) {
      if (!state.welcomeOpen) return;
      state.welcomeOpen = false;
    } else {
      const idx = state.openFiles.indexOf(key);
      if (idx === -1) return;
      state.openFiles.splice(idx, 1);
      if (active === key) {
        neighbour = state.openFiles[idx] ?? state.openFiles[idx - 1] ?? null;
      }
    }

    if (active !== key) return;

    if (neighbour) {
      void router.visit(hrefForFile(neighbour));
      return;
    }
    if (state.openFiles.length > 0) {
      const last = state.openFiles[state.openFiles.length - 1];
      if (last) {
        void router.visit(hrefForFile(last));
        return;
      }
    }
    void router.visit("/");
  };

  return { tabs, activeKey, welcomeOpen, syncFromPath, closeTab };
}
