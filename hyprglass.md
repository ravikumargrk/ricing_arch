# HyprGlass setup notes

This was done against the actual installed Hyprland build on this machine:

- `Hyprland 0.56.0` built from `main`
- ABI hash: `fed60b105f5bc2840503411d4aa1d40540277e64_aq_0.15_hu_0.14_hg_0.5_hc_0.1_hlg_0.6`
- `hyprpm` was not present, so I used the actual project’s compatible workflow and built the plugin locally against the installed headers.

## What I did

1. Confirmed compatibility
   - This is a git build, not a release tarball.
   - HyprGlass documents `main` for `hyprland-git` and `hyprland-0.56` for release-branch builds.
   - Since this machine is running a git main snapshot, `main` was the correct branch.

2. Built HyprGlass locally against the installed Hyprland
   - Cloned the upstream repo.
   - Built the `main` branch with `make`.
   - This produced `hyprglass.so` using the exact local Hyprland headers/ABI.

3. Installed the plugin
   - Put the built plugin at:
     `~/.config/hypr/plugins/hyprglass.so`
   - Loaded it in the main Hyprland config using:

```lua
hl.plugin.load("/home/ravi/.config/hypr/plugins/hyprglass.so")
```

4. Configured the glass effect
   - Wrapped the config in `if hl.plugin.hyprglass then ... end`
   - Set the default preset to a custom acrylic preset tuned for the wallpaper look.
   - Used:
     - strong blur
     - low refraction to keep it frosted, not distorted
     - subtle tint
     - soft specular/fresnel
     - glass opacity near 1.0
     - no heavy chromatic distortion

```lua
if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.preset("foot-acrylic", {
        blur_strength        = 3.2,
        blur_iterations      = 3,
        refraction_strength  = 0.14,
        refraction_flow      = 0.65,
        refraction_spread    = 0.32,
        chromatic_aberration = 0.08,
        fresnel_strength     = 0.18,
        fresnel_tint         = 0.15,
        specular_strength    = 0.18,
        glass_opacity        = 1.0,
        edge_thickness       = 0.06,
        lens_distortion      = 0.04,
        tint_color           = 0x789BBC20,
        dark = {
            brightness    = 0.94,
            contrast      = 0.94,
            saturation    = 0.88,
            vibrancy      = 0.18,
            adaptive_dim  = 0.22,
        },
    })

    hg.config({
        enabled           = true,
        manage_window_blur = true,
        skip_opaque_windows = true,
        default_theme     = "dark",
        default_preset    = "foot-acrylic",
    })
end
```

5. Kept the real Hyprland config intact
   - Left the main `~/.config/hypr/hyprland.lua` as the primary config.
   - Only added the plugin load and the plugin preset/config block.
   - Did not touch shipped files in `/usr/share/hypr/`.

6. Fixed the actual Foot transparency behavior
   - The key to getting the right result was realizing Foot itself was contributing the alpha.
   - Foot was using a terminal background alpha of `0.95` with `alpha-mode=all`, which made it too opaque and hid the glass effect.
   - I switched it to a lower terminal alpha and `alpha-mode=matching` so the compositor-produced glass surface stayed visible behind sharp terminal text.

```ini
[colors-dark]
alpha=0.72
alpha-mode=matching
```

7. Verified the active result
   - `hyprctl plugin list` showed `hyprglass` loaded
   - `hyprctl configerrors` was empty
   - `hyprctl hyprglass stats` reported successful blur passes
   - Fresh Foot windows stayed sharp while the background behind them became strongly frosted glass

## Result

The visual target was reached: a frosted, acrylic window surface where the wallpaper is heavily blurred into coarse color regions while terminal text remains crisp.

This is the closest match to the requested layered effect:

- wallpaper
- strong frosted compositor surface
- sharp app content

The important part is that the glass is a compositor surface, not just a transparent window.
