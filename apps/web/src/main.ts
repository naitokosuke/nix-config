import "./style.css";
import { App } from "./ui.ts";

const root = document.querySelector<HTMLElement>("#app");
if (!root) throw new Error("#app element not found");

new App(root).start();
