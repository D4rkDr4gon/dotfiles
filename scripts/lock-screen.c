#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <X11/extensions/Xinerama.h>
#include <Imlib2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define CLOCK_FONT  "Hack Nerd Font Mono:size=72"
#define BANNER_FONT "Hack Nerd Font Mono:size=14"
#define MARGIN 30
#define LINE_GAP 4

static const char *banner[] = {
    "====================================================================================",
    "    \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97   \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97",
    "    \xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97",
    "    \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91   \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x95\x94\xe2\x95\x97 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97",
    "    \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x95\x94\xe2\x95\x90\xe2\x95\x90\xe2\x96\x88\xe2\x96\x88\xe2\x95\x97",
    "    \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91  \xe2\x96\x88\xe2\x96\x88\xe2\x95\x91\xe2\x95\x9a\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x95\x9a\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x95\x94\xe2\x95\x9d\xe2\x96\x88\xe2\x96\x88\xe2\x95\x91 \xe2\x96\x88\xe2\x96\x88\xe2\x95\x97",
    "    \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x90\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90 \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d\xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d  \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d  \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d\xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d   \xe2\x95\x9a\xe2\x95\x90\xe2\x95\x90\xe2\x95\x9d",
    "    -----------  >>> Lucciano Campassi - Cybersecurity Specialist <<<  -----------------",
    "====================================================================================",
};
#define BANNER_LINES (sizeof(banner) / sizeof(banner[0]))

typedef struct {
    Display *dpy;
    Window win;
    int w, h;
    XftDraw *draw;
    XftColor color;
    GC gc;
    Imlib_Image bg;
} MonitorCtx;

static int banner_pixels_h(XftFont *font) {
    int h = 0;
    for (size_t i = 0; i < BANNER_LINES; i++)
        h += font->ascent + font->descent + LINE_GAP;
    return h;
}

static void draw_banner(MonitorCtx *ctx, XftFont *font) {
    int bh = banner_pixels_h(font);
    int y = ctx->h - bh - MARGIN + font->ascent;
    for (size_t i = 0; i < BANNER_LINES; i++) {
        int len = strlen(banner[i]);
        XGlyphInfo ext;
        XftTextExtentsUtf8(ctx->dpy, font, (const unsigned char *)banner[i], len, &ext);
        int x = ctx->w - ext.width - MARGIN;
        XftDrawStringUtf8(ctx->draw, &ctx->color, font,
                          x, y,
                          (const unsigned char *)banner[i], len);
        y += font->ascent + font->descent + LINE_GAP;
    }
}

static void draw_clock(MonitorCtx *ctx, XftFont *font) {
    time_t raw = time(NULL);
    struct tm *tm = localtime(&raw);
    char buf[64];
    strftime(buf, sizeof(buf), "%H:%M:%S", tm);
    int len = strlen(buf);
    XftDrawStringUtf8(ctx->draw, &ctx->color, font,
                      MARGIN, ctx->h - MARGIN,
                      (const unsigned char *)buf, len);
}

static void clear_clock(MonitorCtx *ctx, XftFont *font) {
    int ch = font->ascent + font->descent + MARGIN;
    if (ctx->bg) {
        imlib_context_set_image(ctx->bg);
        imlib_context_set_drawable(ctx->win);
        imlib_render_image_part_on_drawable_at_size(0, ctx->h - ch, 700, ch, 0, ctx->h - ch, 700, ch);
    } else {
        XSetForeground(ctx->dpy, ctx->gc, 0);
        XFillRectangle(ctx->dpy, ctx->win, ctx->gc, 0, ctx->h - ch, 700, ch);
    }
}

static void full_refresh(MonitorCtx *ctx, XftFont *cf, XftFont *bf) {
    if (ctx->bg) {
        imlib_context_set_image(ctx->bg);
        imlib_context_set_drawable(ctx->win);
        imlib_render_image_on_drawable(0, 0);
    } else {
        XSetForeground(ctx->dpy, ctx->gc, 0);
        XFillRectangle(ctx->dpy, ctx->win, ctx->gc, 0, 0, ctx->w, ctx->h);
    }
    draw_banner(ctx, bf);
    draw_clock(ctx, cf);
    XFlush(ctx->dpy);
}

static Imlib_Image create_wallpaper_bg(const char *path, int mw, int mh) {
    Imlib_Image img = imlib_load_image(path);
    if (!img) return NULL;

    imlib_context_set_image(img);
    int iw = imlib_image_get_width();
    int ih = imlib_image_get_height();

    double scale_x = (double)mw / iw;
    double scale_y = (double)mh / ih;

    int src_x = 0, src_y = 0, src_w = iw, src_h = ih;

    if (scale_x > scale_y) {
        src_h = (int)(mh / scale_x + 0.5);
        src_y = (ih - src_h) / 2;
    } else {
        src_w = (int)(mw / scale_y + 0.5);
        src_x = (iw - src_w) / 2;
    }

    Imlib_Image result = imlib_create_cropped_scaled_image(src_x, src_y, src_w, src_h, mw, mh);
    imlib_context_set_image(img);
    imlib_free_image();

    if (result) {
        imlib_context_set_image(result);
        imlib_image_blur(25);
    }

    return result;
}

int main(int argc, char *argv[]) {
    const char *wallpaper_path = NULL;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--wallpaper") == 0 && i + 1 < argc) {
            wallpaper_path = argv[++i];
        } else if (strcmp(argv[i], "--help") == 0) {
            printf("Usage: %s [--wallpaper <path>]\n", argv[0]);
            return 0;
        }
    }

    Display *dpy;
    Window root;
    int screen, n_monitors = 1;
    XftFont *clock_font = NULL, *banner_font = NULL;
    XRenderColor rend_color = {0xbbbb, 0xbbbb, 0xbbbb, 0xffff};
    XEvent ev;
    int running = 1;
    time_t last_sec = 0;

    dpy = XOpenDisplay(NULL);
    if (!dpy) { fprintf(stderr, "Can't open display\n"); return 1; }
    screen = DefaultScreen(dpy);
    root = RootWindow(dpy, screen);

    clock_font = XftFontOpenName(dpy, screen, CLOCK_FONT);
    banner_font = XftFontOpenName(dpy, screen, BANNER_FONT);
    if (!clock_font) {
        fprintf(stderr, "fallback clock font\n");
        clock_font = XftFontOpenName(dpy, screen, "mono:size=72");
    }
    if (!banner_font) {
        fprintf(stderr, "fallback banner font\n");
        banner_font = XftFontOpenName(dpy, screen, "mono:size=14");
    }
    if (!clock_font || !banner_font) {
        fprintf(stderr, "Can't load any fonts\n");
        return 1;
    }

    XineramaScreenInfo *xine = XineramaQueryScreens(dpy, &n_monitors);
    if (!xine) n_monitors = 1;

    int virt_w = 0, virt_h = 0;
    if (xine) {
        for (int i = 0; i < n_monitors; i++) {
            int r = xine[i].x_org + xine[i].width;
            int b = xine[i].y_org + xine[i].height;
            if (r > virt_w) virt_w = r;
            if (b > virt_h) virt_h = b;
        }
    } else {
        virt_w = DisplayWidth(dpy, screen);
        virt_h = DisplayHeight(dpy, screen);
    }

    imlib_context_set_display(dpy);
    imlib_context_set_visual(DefaultVisual(dpy, screen));
    imlib_context_set_colormap(DefaultColormap(dpy, screen));

    MonitorCtx *ctxs = calloc(n_monitors, sizeof(MonitorCtx));

    for (int i = 0; i < n_monitors; i++) {
        int mx = xine ? xine[i].x_org : 0;
        int my = xine ? xine[i].y_org : 0;
        int mw = xine ? xine[i].width : virt_w;
        int mh = xine ? xine[i].height : virt_h;

        if (wallpaper_path) {
            ctxs[i].bg = create_wallpaper_bg(wallpaper_path, mw, mh);
            if (!ctxs[i].bg) {
                fprintf(stderr, "failed to load wallpaper '%s' for monitor %d\n", wallpaper_path, i);
            }
        }

        if (!ctxs[i].bg) {
            imlib_context_set_drawable(root);
            Imlib_Image cap = imlib_create_image_from_drawable(0, mx, my, mw, mh, 1);
            if (cap) {
                imlib_context_set_image(cap);
                imlib_image_blur(25);
                ctxs[i].bg = cap;
            } else {
                ctxs[i].bg = NULL;
                fprintf(stderr, "failed to capture monitor %d\n", i);
            }
        }
    }

    for (int i = 0; i < n_monitors; i++) {
        ctxs[i].dpy = dpy;
        ctxs[i].w = xine ? xine[i].width : virt_w;
        ctxs[i].h = xine ? xine[i].height : virt_h;

        XSetWindowAttributes attrs;
        attrs.override_redirect = True;
        attrs.background_pixel = 0;
        attrs.backing_store = NotUseful;
        attrs.save_under = False;

        ctxs[i].win = XCreateWindow(dpy, root,
                    xine ? xine[i].x_org : 0,
                    xine ? xine[i].y_org : 0,
                    ctxs[i].w, ctxs[i].h, 0, CopyFromParent,
                    InputOutput, CopyFromParent,
                    CWOverrideRedirect | CWBackPixel |
                    CWBackingStore | CWSaveUnder, &attrs);

        XMapRaised(dpy, ctxs[i].win);

        ctxs[i].gc = XCreateGC(dpy, ctxs[i].win, 0, NULL);
        ctxs[i].draw = XftDrawCreate(dpy, ctxs[i].win,
                          DefaultVisual(dpy, screen),
                          DefaultColormap(dpy, screen));
        if (!ctxs[i].draw) {
            fprintf(stderr, "XftDrawCreate failed for monitor %d\n", i);
        }
        XftColorAllocValue(dpy, DefaultVisual(dpy, screen),
                           DefaultColormap(dpy, screen),
                           &rend_color, &ctxs[i].color);
    }
    if (xine) XFree(xine);

    XSelectInput(dpy, root, KeyPressMask | ButtonPressMask);
    XFlush(dpy);
    usleep(500000);

    for (int i = 0; i < n_monitors; i++)
        full_refresh(ctxs + i, clock_font, banner_font);
    XSync(dpy, False);
    usleep(200000);

    while (XPending(dpy))
        XNextEvent(dpy, &ev);

    int kgrab = XGrabKeyboard(dpy, root, False,
                  GrabModeAsync, GrabModeAsync, CurrentTime);
    if (kgrab != GrabSuccess) {
        fprintf(stderr, "XGrabKeyboard failed: %d\n", kgrab);
    }

    int pgrab = XGrabPointer(dpy, root, False, ButtonPressMask,
                 GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
    if (pgrab != GrabSuccess) {
        fprintf(stderr, "XGrabPointer failed: %d\n", pgrab);
    }

    last_sec = time(NULL);

    while (running) {
        while (XPending(dpy)) {
            XNextEvent(dpy, &ev);
            if (ev.type == KeyPress || ev.type == ButtonPress) {
                running = 0;
            }
        }

        time_t now = time(NULL);
        if (now != last_sec && running) {
            last_sec = now;
            for (int i = 0; i < n_monitors; i++) {
                clear_clock(ctxs + i, clock_font);
                draw_clock(ctxs + i, clock_font);
            }
            XFlush(dpy);
        }
        usleep(50000);
    }

    XUngrabKeyboard(dpy, CurrentTime);
    XUngrabPointer(dpy, CurrentTime);

    for (int i = 0; i < n_monitors; i++) {
        if (ctxs[i].bg) {
            imlib_context_set_image(ctxs[i].bg);
            imlib_free_image();
        }
        XftColorFree(dpy, DefaultVisual(dpy, screen),
                     DefaultColormap(dpy, screen), &ctxs[i].color);
        XftDrawDestroy(ctxs[i].draw);
        XFreeGC(dpy, ctxs[i].gc);
        XDestroyWindow(dpy, ctxs[i].win);
    }
    XftFontClose(dpy, clock_font);
    XftFontClose(dpy, banner_font);
    free(ctxs);
    XCloseDisplay(dpy);
    return 0;
}
