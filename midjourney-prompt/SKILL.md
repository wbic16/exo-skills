---
name: midjourney-prompt
description: "Compose ready-to-paste Midjourney /imagine prompts from natural language descriptions. Use when: generating image prompts for Midjourney, composing /imagine commands, creating art direction prompts, or when someone needs a Midjourney-formatted prompt they can copy into Discord."
---

# Midjourney Prompt Composer

Translate natural descriptions into optimized `/imagine` prompts for Midjourney.

## Workflow

1. Get the subject/scene description from the user
2. Compose a `/imagine` prompt using Midjourney syntax
3. Output the final prompt in a code block, ready to copy/paste into Discord

## Prompt Structure

```
/imagine prompt: [subject], [style/mood], [lighting], [composition], [medium] --[parameters]
```

### Composition Rules

- Lead with the **subject** — what's in the image
- Follow with **style/mood** descriptors — aesthetic, emotion, atmosphere
- Add **technical terms** — lighting, camera angle, medium, texture
- End with **parameters** after `--`
- Use commas to separate concepts, not sentences
- Avoid filler words ("a photo of", "an image showing")
- Be specific over generic ("amber sidelight" beats "nice lighting")
- Front-load important concepts — Midjourney weighs earlier terms more heavily

### Weighting

- `::2` increases weight: `crystal::2, dark stone` emphasizes crystal
- `::0.5` decreases weight
- `--no [thing]` excludes elements: `--no text, watermark`

## Parameters Reference

See `references/parameters.md` for the full parameter list. Always include at minimum:

- `--ar` (aspect ratio) — default to `--ar 16:9` for landscapes, `--ar 1:1` for portraits/icons, `--ar 9:16` for vertical
- `--v 6.1` (version) — use latest unless user specifies otherwise

Common additions:
- `--s` (stylize: 0-1000, default 100)
- `--c` (chaos: 0-100, default 0)
- `--q` (quality: .25, .5, 1)
- `--style raw` for photorealistic/less stylized output

## Output Format

Always output the final prompt in a fenced code block:

```
/imagine prompt: luminous crystal emerging from volcanic basalt, warm amber and gold light radiating from fracture lines, macro photography, shallow depth of field, dawn atmosphere, ethereal glow --ar 1:1 --v 6.1 --s 250
```

If the user's request is ambiguous, offer 2-3 variations with different interpretations.

## Style Vocabulary

When the user gives a vague direction, draw from these proven terms:

- **Photorealism:** editorial photography, DSLR, 85mm lens, f/1.8, bokeh, golden hour
- **Painterly:** oil painting, impasto, chiaroscuro, Renaissance, Baroque
- **Digital art:** concept art, matte painting, artstation trending, cinematic
- **Abstract:** generative art, geometric, prismatic, iridescent, fractal
- **Ethereal:** bioluminescent, translucent, gossamer, aurora, celestial
- **Dark/moody:** noir, tenebrist, obsidian, smoke, dramatic shadows
- **Warm/inviting:** amber light, hearthglow, golden, pastoral, soft diffusion
