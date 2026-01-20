import XMonad
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout(Tall,Mirror,Full)
import qualified XMonad.StackSet as W

-- Replace normal Tall layout with one that can grow/shrink by the pixel
fineTall = Tall 1 (1/1920) (1/2)

-- three extra workspaces on keys 0, -, =
-- one more extra workspace on pause/break
extraWorkspaces = [(xK_0, "10"),(xK_minus, "11"),(xK_equal, "12"),(xK_Pause, "13")]

-- Ignore firefox notification windows, so they go into the top-right of the screen.
myManageHook = composeAll
	[
		appName =? "Alert" --> doIgnore
	]

main = do
	xmonad $ ewmh defaultConfig
		{
			terminal = "terminator",
			modMask = myModMask,
			handleEventHook = fullscreenEventHook,
			layoutHook = fineTall ||| Mirror fineTall ||| Full,
			manageHook = myManageHook <+> manageHook defaultConfig,
			-- four extra workspaces
			workspaces = map show [1 .. 13]
		} `additionalKeys` (myKeys)

myKeys =
	[
	((myModMask, xK_p), spawn "dmenu_run"),
	((myModMask, xK_e), spawn "dmenu-unicode"),
	((myModMask, xK_s), spawn "setup-screens"),
	((myModMask, xK_c), spawn "screenshot"),
	((myModMask, xK_x), spawn "screenshot-window 0"),
	((myModMask, xK_v), spawn "typepaste --release-keys")
	] ++ [
		-- switch to extra workspaces
		((myModMask, key), (windows $ W.greedyView ws))
		| (key,ws) <- extraWorkspaces
	] ++ [
		-- move window to extra workspaces
		((myModMask .|. shiftMask, key), (windows $ W.shift ws))
		| (key,ws) <- extraWorkspaces
	]

myModMask = mod4Mask
