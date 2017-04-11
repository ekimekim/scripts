import XMonad
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
 
main = do
	xmonad $ ewmh defaultConfig
		{
			terminal = "terminator",
			modMask = myModMask,
			handleEventHook = fullscreenEventHook
		}`additionalKeys`[
		((myModMask, xK_p), spawn "dmenu_run")
		]

myModMask = mod4Mask
