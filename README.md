# [Wake](https://github.com/wake-tools/Wake) Samples

A collection of **JIT C** _`.jc`_ demos running instantly with **Wake** —  
no build system, no waiting, just **code → run**.

All examples are adapted from the official **Sokol samples** (zlib/libpng license)  
and converted to Wake’s live runtime environment with **memory bound checking**,  
**hot reload**, and **debug UI** support.

---

## Multi-Editor Support

Wake samples now include
- ✅ **VS Code** support with proper include paths and C99 settings  
- ✅ **IntelliSense** auto-completion and diagnostics  
- ✅ **clangd / [Cursor](https://cursor.com/download)** support for fast and accurate code navigation

Simply open the sample folder in your favorite editor
all paths are already configured in `.vscode/c_cpp_properties.json`.

---

## 🚀 Run a Sample

```bash
# From the sample folder
wake clear-sapp.jc
wake cube-sapp.jc
wake imgui-sapp.jc
