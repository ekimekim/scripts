import XMonad
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout(Tall,Mirror,Full)

-- Replace normal Tall layout with one that can grow/shrink by the pixel
fineTall = Tall 1 (1/1920) (1/2)

main = do
	xmonad $ ewmh defaultConfig
		{
			terminal = "terminator",
			modMask = myModMask,
			handleEventHook = fullscreenEventHook,
			layoutHook = fineTall ||| Mirror fineTall ||| Full
		}`additionalKeys`[
		((myModMask, xK_p), spawn "dmenu_run"),
		((myModMask, xK_e), spawn "dmenu-unicode")
		]

myModMask = mod4Mask
