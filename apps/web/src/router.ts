import type { Route } from "./types.ts";

type Listener = (route: Route) => void;

interface NavigateEventLike extends Event {
  readonly canIntercept: boolean;
  readonly hashChange: boolean;
  readonly downloadRequest: string | null;
  readonly destination: { readonly url: string };
  intercept(options?: { handler?: () => void | Promise<void> }): void;
}

interface NavigationLike {
  addEventListener(type: "navigate", listener: (event: NavigateEventLike) => void): void;
  navigate(url: string, options?: { history?: "auto" | "push" | "replace" }): unknown;
}

function getNavigation(): NavigationLike | undefined {
  return (globalThis as { navigation?: NavigationLike }).navigation;
}

function parse(url: URL): Route {
  const path = decodeURIComponent(url.pathname.replace(/^\/+/, "").replace(/\/+$/, ""));
  if (path === "" || path === "home") return { kind: "home" };
  if (path.startsWith("file/")) return { kind: "file", path: path.slice("file/".length) };
  return { kind: "home" };
}

export function routeToHref(route: Route): string {
  if (route.kind === "home") return "/";
  return `/file/${route.path}`;
}

export class Router {
  private readonly listeners = new Set<Listener>();
  private currentRoute: Route;

  constructor() {
    this.currentRoute = parse(new URL(location.href));
    const nav = getNavigation();
    if (nav) {
      nav.addEventListener("navigate", (event) => {
        if (!event.canIntercept || event.hashChange || event.downloadRequest !== null) return;
        const url = new URL(event.destination.url);
        if (url.origin !== location.origin) return;
        event.intercept({
          handler: () => {
            this.currentRoute = parse(url);
            this.emit();
          },
        });
      });
    } else {
      window.addEventListener("popstate", () => {
        this.currentRoute = parse(new URL(location.href));
        this.emit();
      });
    }
  }

  get route(): Route {
    return this.currentRoute;
  }

  navigate(route: Route): void {
    const href = routeToHref(route);
    if (href === routeToHref(this.currentRoute)) return;
    const nav = getNavigation();
    if (nav) {
      nav.navigate(href);
    } else {
      history.pushState({}, "", href);
      this.currentRoute = route;
      this.emit();
    }
  }

  subscribe(listener: Listener): () => void {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  private emit(): void {
    for (const listener of this.listeners) listener(this.currentRoute);
  }
}
