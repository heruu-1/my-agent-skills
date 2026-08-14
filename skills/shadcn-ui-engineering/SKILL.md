---
name: shadcn-ui-engineering
description: >-
  Use this skill when building modern frontend interfaces with React, Next.js, and TailwindCSS using shadcn/ui components. Enforces clean component composition, accessibility (Radix UI primitives), and copy-paste modularity.
---

# `shadcn/ui` Component Engineering

`shadcn/ui` is the industry standard for modern React/Next.js/Tailwind components. Unlike traditional component libraries (Material UI, Ant Design), components are copied directly into the project codebase under `components/ui/`, giving full control over styling and logic.

## Core Setup & Architecture

### 1. Initialization
```bash
# Initialize shadcn/ui in a React / Next.js project
npx shadcn@latest init
```

### 2. Adding Components
```bash
# Add essential accessible UI primitives
npx shadcn@latest add button card dialog dropdown-menu form input table tabs toast
```

### 3. Component Composition Rules
- **Use `cn()` for Class Merging**: Always use the `cn()` utility (`clsx` + `tailwind-merge`) when applying dynamic classes to avoid Tailwind specificity conflicts:
  ```tsx
  import { cn } from "@/lib/utils"
  
  export function CustomBadge({ className, children, ...props }: BadgeProps) {
    return (
      <div className={cn("inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold", className)} {...props}>
        {children}
      </div>
    )
  }
  ```
- **Type-Safe Forms**: Combine shadcn/ui `Form` with `react-hook-form` and `zod` for automatic client-side schema validation.
- **Accessibility by Default**: Never strip Radix UI `aria-*` attributes or focus ring classes (`focus-visible:ring-2`).
