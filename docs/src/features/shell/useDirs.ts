import { reactive } from "vue";
import { ancestorsOf } from "../../data.ts";

const open = reactive(new Set<string>());

export function useDirs(): {
  isOpen: (path: string) => boolean;
  toggle: (path: string) => void;
  ensureAncestors: (filePath: string) => void;
} {
  return {
    isOpen: (path) => open.has(path),
    toggle: (path) => {
      if (open.has(path)) open.delete(path);
      else open.add(path);
    },
    ensureAncestors: (filePath) => {
      for (const ancestor of ancestorsOf(filePath)) open.add(ancestor);
    },
  };
}
