# SimCH Business Project Rules

This workspace contains the code for **SimCH Business**, a long-term business simulation game built with **Godot 4** using **GDScript**.

The project follows a modular architecture so every system can be reused in future SimCH games.

## Core Development Rules

- **Build one feature at a time**: Focus on implementing a single feature thoroughly before moving to the next.
- **Sprint Boundaries**: Never implement features outside the current active sprint (refer to `roadmap.md`).
- **Composition over Inheritance**: Prefer composition over inheritance. Combine smaller nodes, components, or custom resources.
- **Single Responsibility**: Keep scripts focused on a single responsibility.
- **Descriptive Naming**: Use descriptive names for nodes, variables, functions, and files.
- **Minimal, Meaningful Comments**: Add comments only where they improve understanding. Do not write self-explanatory comments.
- **Decoupled Architecture**: Avoid unnecessary dependencies between systems. Keep UI, gameplay, data, and managers separated.
- **Reusability and Testability**: Every new system must be designed to be reusable and testable.
- **Strict Scope**: Do not refactor unrelated code.
- **Preserve Architecture**: Preserve the existing architecture unless explicitly instructed otherwise.
- **Ask for Clarification**: If requirements are unclear, ask the user instead of making assumptions.
- **Standards**: Follow Godot 4 best practices and the official GDScript style guide.
- **Bahasa**: implementation plan atau file doc .md gunakan bahasa indonesia.
