# Midjourney Parameters Reference

## Core Parameters

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `--ar` | W:H ratio | 1:1 | Aspect ratio. Common: `16:9`, `9:16`, `4:3`, `3:2`, `1:1`, `21:9` |
| `--v` | 5, 5.1, 5.2, 6, 6.1 | 6.1 | Model version |
| `--s` | 0–1000 | 100 | Stylize. Low = literal, high = artistic interpretation |
| `--c` | 0–100 | 0 | Chaos. Higher = more varied/unexpected results |
| `--q` | .25, .5, 1 | 1 | Quality. Lower = faster/cheaper, higher = more detail |
| `--no` | text list | — | Negative prompt. Exclude elements: `--no text, watermark, frame` |
| `--seed` | 0–4294967295 | random | Reproducibility. Same seed + prompt = similar result |
| `--tile` | — | off | Seamless tiling pattern |
| `--repeat` | 2–40 | 1 | Run the same prompt multiple times |

## Style Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `--style raw` | — | Less Midjourney aesthetic, more literal/photorealistic |
| `--niji` | — | Anime/illustration model (use instead of `--v`) |
| `--niji 6` | — | Latest anime model |

## Aspect Ratio Cheat Sheet

| Use Case | Ratio | Flag |
|----------|-------|------|
| Square (avatar, icon, social) | 1:1 | `--ar 1:1` |
| Landscape (desktop wallpaper) | 16:9 | `--ar 16:9` |
| Portrait (phone wallpaper) | 9:16 | `--ar 9:16` |
| Ultrawide (banner) | 21:9 | `--ar 21:9` |
| Photo standard | 3:2 | `--ar 3:2` |
| Classic frame | 4:3 | `--ar 4:3` |
| Tall portrait | 2:3 | `--ar 2:3` |

## Stylize Scale Guide

| Value | Effect |
|-------|--------|
| `--s 0` | Minimal artistic interpretation, very literal |
| `--s 50` | Slight artistic touch |
| `--s 100` | Default balance |
| `--s 250` | Strong artistic interpretation |
| `--s 500` | Very stylized |
| `--s 750–1000` | Maximum artistic freedom, may diverge from prompt |

## Multi-Prompt Weighting

Separate concepts with `::` and assign weights:

```
/imagine prompt: crystal::2 dark stone::1 golden light::1.5 --ar 1:1 --v 6.1
```

- Default weight is 1
- Higher weight = more influence on the result
- Negative weights remove concepts: `crystal:: dark stone::-0.5`

## Image Prompts

Paste an image URL before the text prompt to use as reference:

```
/imagine prompt: https://example.com/ref.jpg luminous crystal, warm light --ar 1:1 --v 6.1
```

- Multiple image URLs supported
- `--iw 0–2` controls image vs text influence (default 1)
