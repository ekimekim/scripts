import XMonad
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
 
main = do
	xmonad $ defaultConfig
		{
			terminal = "terminator",
			modMask = myModMask
		}`additionalKeys`[
		((myModMask, xK_p), spawn "dmenu_run")
		]

myModMask = mod4Mask
