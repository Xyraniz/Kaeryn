import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const build = spawnSync(process.execPath, [path.join(root, "scripts", "build.mjs")], {encoding: "utf8"});
if (build.status !== 0) throw new Error(build.stderr || "Bundle build failed");

const bundlePath = path.join(root, "dist", "Kaeryn.luau");
const bundle = fs.readFileSync(bundlePath, "utf8");
const sourceFiles = [];
const sourceText = new Map();
function collect(dir) {
    for (const item of fs.readdirSync(dir, {withFileTypes: true})) {
        const full = path.join(dir, item.name);
        if (item.isDirectory()) collect(full);
        else if (item.name.endsWith(".luau")) {
            sourceFiles.push(full);
            sourceText.set(path.relative(root, full).split(path.sep).join("/"), fs.readFileSync(full, "utf8"));
        }
    }
}
collect(path.join(root, "src", "Kaeryn"));

const unresolved = bundle.match(/require\(\s*['"]\.\//g);
if (unresolved) throw new Error("Relative module require remained in the bundle");
if (!bundle.includes('return __kaeryn_require("src/Kaeryn/Init.luau")')) {
    throw new Error("Bundle entry does not return the Kaeryn library");
}
if (!bundle.includes("function library:resolve_flag") || !bundle.includes("function library:set_theme")) {
    throw new Error("Bundle is missing the flag or theme API");
}
if (!bundle.includes("function library:begin_pointer_drag") || !bundle.includes("function library:load_config")) {
    throw new Error("Bundle is missing the input or config API");
}
for (const file of ["src/Kaeryn/Controls/Slider.luau", "src/Kaeryn/Controls/Colorpicker.luau"]) {
    if (/library:connection\(uis\.Input(?:Changed|Ended)/.test(sourceText.get(file))) {
        throw new Error(`${file} still registers per-control global drag listeners`);
    }
}
if (sourceText.get("src/Kaeryn/Config/ConfigManager.luau").indexOf("config_validators[key]") < 0) {
    throw new Error("Config loading no longer validates values before applying them");
}
const moduleCount = (bundle.match(/\["src\/Kaeryn\//g) || []).length;
if (moduleCount !== sourceFiles.length) {
    throw new Error(`Expected ${sourceFiles.length} bundled modules, got ${moduleCount}`);
}
process.stdout.write(`Bundle checks passed (${moduleCount} modules, ${bundle.length} chars)\n`);
