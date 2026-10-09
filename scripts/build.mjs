import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const sourceRoot = path.join(root, "src", "Kaeryn");
const entry = path.join(sourceRoot, "Init.luau");
const modules = new Map();
const requirePattern = /require\((['"])(\.\/[^'"]+)\1\)/g;

function moduleId(file) {
    return path.relative(root, file).split(path.sep).join("/");
}

function resolveModule(from, request) {
    let target = path.resolve(path.dirname(from), request);
    if (path.extname(target) === "") target += ".luau";
    if (!target.startsWith(sourceRoot + path.sep) && target !== sourceRoot) {
        throw new Error(`Module path escapes src/Kaeryn: ${request}`);
    }
    if (!fs.existsSync(target)) throw new Error(`Missing module: ${target}`);
    return target;
}

function visit(file) {
    if (modules.has(file)) return;
    const source = fs.readFileSync(file, "utf8").replace(/[ \t]+$/gm, "");
    const dependencies = [];
    for (const match of source.matchAll(requirePattern)) {
        dependencies.push({request: match[2], target: resolveModule(file, match[2])});
    }
    modules.set(file, {source, dependencies});
    for (const dependency of dependencies) visit(dependency.target);
}

visit(entry);

const entries = [...modules.entries()].sort(([a], [b]) => moduleId(a).localeCompare(moduleId(b)));
const factories = entries.map(([file, module]) => {
    let source = module.source.replace(requirePattern, (_, _quote, request) => {
        const dependency = resolveModule(file, request);
        return `__kaeryn_require(${JSON.stringify(moduleId(dependency))})`;
    });
    return `    [${JSON.stringify(moduleId(file))}] = function(__kaeryn_require)\n${source}\n    end,`;
}).join("\n");

const bundle = `local __kaeryn_modules = {\n${factories}\n}\n\nlocal __kaeryn_cache = {}\nlocal function __kaeryn_require(id)\n    if __kaeryn_cache[id] ~= nil then return __kaeryn_cache[id] end\n    local factory = __kaeryn_modules[id]\n    if not factory then error("Unknown bundled module: " .. tostring(id), 2) end\n    local value = factory(__kaeryn_require)\n    __kaeryn_cache[id] = value\n    return value\nend\n\nreturn __kaeryn_require(${JSON.stringify(moduleId(entry))})\n`;

const output = path.join(root, "dist", "Kaeryn.luau");
fs.mkdirSync(path.dirname(output), {recursive: true});
fs.writeFileSync(output, bundle, "utf8");
process.stdout.write(`Built ${path.relative(root, output)} from ${modules.size} modules\n`);
