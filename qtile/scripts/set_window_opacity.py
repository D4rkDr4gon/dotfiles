import sys
import time
from libqtile.command.client import CommandClient


def main():
    if len(sys.argv) < 3:
        return

    target_id = int(sys.argv[1])
    opacity = float(sys.argv[2])

    for attempt in range(5):
        c = CommandClient()

        for s_idx in range(10):
            try:
                screen = c.navigate("screen", s_idx)
                success, groups = screen.items("group")
                for g_name in groups:
                    group = c.navigate("group", g_name)
                    success, windows = group.items("window")
                    for w_idx in windows:
                        win = c.navigate("group", g_name).navigate("window", w_idx)
                        info = win.call("info")
                        if info.get("id") == target_id:
                            win.call("set_opacity", opacity)
                            return
            except Exception:
                break

        time.sleep(0.3)

    print(f"set_window_opacity: window {target_id} not found after 5 attempts", file=sys.stderr)


if __name__ == "__main__":
    main()
